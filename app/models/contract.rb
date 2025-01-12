# frozen_string_literal: true

class Contract < ApplicationRecord
  has_many :targets, inverse_of: :contract, dependent: :destroy
  has_many :plans,   inverse_of: :contract, dependent: :destroy
  has_many :reports, inverse_of: :contract

  validates_presence_of :start_date, :end_date

  scope :current, -> { where('end_date > ?', Date.today).order(start_date: :desc).first }

  scope :between, ->(from, to) { where('end_date >= ? AND start_date <= ?', from, to) }

  def name
    id.to_s + ': ' + start_date.strftime('%m/%Y') + ' - ' + end_date.strftime('%m/%Y')
  end

  def url_params
    '?from=' + start_date.strftime('%Y-%m-%d') + '&to=' + end_date.strftime('%Y-%m-%d')
  end
end
