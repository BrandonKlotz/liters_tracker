# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :technology, inverse_of: :reports
  belongs_to :user,       inverse_of: :reports
  belongs_to :contract,   inverse_of: :reports
  serialize :model_gid

  scope :only_districts,  -> { where('model_gid ILIKE ?', '%/District/%') }
  scope :only_sectors,    -> { where('model_gid ILIKE ?', '%/Sector/%') }
  scope :only_cells,      -> { where('model_gid ILIKE ?', '%/Cell/%') }
  scope :only_villages,   -> { where('model_gid ILIKE ?', '%/Village/%') }
  scope :only_facilities, -> { where('model_gid ILIKE ?', '%/Facility/%') }
  scope :within_month, ->(date) { where(date: date.beginning_of_month..date.end_of_month) }

  def self.related_to(record)
    where(model_gid: record.to_global_id.to_s)
  end

  def self.related_to_facility(facility, only_ary: false)
    reports = related_to(facility)

    return reports.pluck(:id) if only_ary

    reports
  end

  def self.related_to_village(village, only_ary: false)
    report_ids = []
    report_ids << related_to(village).pluck(:id)
    village.facilities.each { |facility| report_ids << related_to_facility(facility, only_ary: true) }

    return report_ids.flatten.uniq if only_ary

    where(id: report_ids.flatten.uniq)
  end

  def self.related_to_cell(cell, only_ary: false)
    report_ids = []
    report_ids << related_to(cell).pluck(:id)
    cell.villages.each { |village| report_ids << related_to_village(village, only_ary: true) }

    return report_ids.flatten.uniq if only_ary

    where(id: report_ids.flatten.uniq)
  end

  def self.related_to_sector(sector, only_ary: false)
    report_ids = []
    report_ids << related_to(sector).pluck(:id)
    sector.cells.each { |cell| report_ids << related_to_cell(cell, only_ary: true) }

    return report_ids.flatten.uniq if only_ary

    where(id: report_ids.flatten.uniq)
  end

  def self.related_to_district(district)
    report_ids = []
    report_ids << related_to(district).pluck(:id)
    district.sectors.each { |sector| report_ids << Report.related_to_sector(sector, only_ary: true) }

    where(id: report_ids.flatten.uniq)
  end

  def self.earliest_date
    self.all.order(date: :asc).first.date
  end

  def self.latest_date
    self.all.order(date: :asc).last.date
  end

  def self.key_params_are_missing?(batch_process_params)
    batch_process_params[:technology_id].blank? ||
      batch_process_params[:contract_id].blank? ||
      batch_process_params[:reports].count.zero?
  end

  def self.batch_process(batch_report_params, user_id)
    technology_id = batch_report_params[:technology_id].to_i
    contract_id = batch_report_params[:contract_id].to_i

    batch_report_params[:reports].each do |report_params|
      next if report_params[:distributed].blank? && report_params[:checked].blank?

      process(report_params, technology_id, contract_id, user_id)
    end
  end

  def self.process(report_params, technology_id, contract_id, user_id)
    report = Report.where(date: report_params[:date], model_gid: report_params[:model_gid], technology_id: technology_id).first_or_initialize
    report.tap do |rep|
      rep.contract_id = contract_id
      rep.user_id = user_id
      rep.distributed = report_params[:distributed]
      rep.checked = report_params[:checked]
      rep.people = report_params[:people]
      rep.households = report_params[:households]
    end
    report.save
  end

  def model
    GlobalID::Locator.locate model_gid
  end

  def people_served
    return people if people&.positive?

    model_gid.include?('Facility') && model.population&.positive? ? model.population : (technology.default_impact * distributed.to_i)
  end

  def households_served
    return households if households&.positive?

    model_gid.include?('Facility') && model.households&.positive? ? model.households : (technology.default_household_impact * distributed.to_i)
  end

  def impact
    mode_gid.include?('Facility') ? model.impact * distributed.to_i : people_served
  end
end
