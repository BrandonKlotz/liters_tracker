# frozen_string_literal: true

module ApplicationHelper
  def bootstrap_class_for(flash_type)
    Constants::Application::BOOTSTRAP_CLASSES[flash_type.to_sym] || flash_type.to_s
  end

  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end

  def human_date(date)
    return '-' if date.nil?

    date&.strftime('%b %-d, %Y')
  end

  def human_datetime(datetime)
    datetime&.strftime('%-m/%-d @ %l:%M:%S %p %Z')
  end

  def human_number(integer)
    return '-' if integer.nil? || integer.zero?

    number_with_delimiter(integer, delimiter: ',')
  end

  def form_date(date)
    date&.strftime('%Y-%m-%d')
  end

  def form_datetime(datetime)
    datetime&.strftime('%Y-%m-%dT%H:%M')
  end

  def flash_messages(_opts = {})
    flash.each do |msg_type, message|
      concat(
        content_tag(:div, message, class: "alert alert-#{bootstrap_class_for(msg_type)} alert-dismissable fade show", role: 'alert') do
          concat content_tag(:button, 'x', class: 'close', data: { dismiss: 'alert' })
          concat message
        end
      )
    end
    nil
  end
end
