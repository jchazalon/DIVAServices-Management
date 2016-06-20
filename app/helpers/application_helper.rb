module ApplicationHelper

  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} alert-dismissible", role: 'alert') do
        concat(content_tag(:button, class: 'close', data: { dismiss: 'alert' }) do
          concat content_tag(:span, '&times;'.html_safe, 'aria-hidden' => true)
          concat content_tag(:span, 'Close', class: 'sr-only')
        end)
        concat message
      end)
    end
    nil
  end

  def actions(algorithm)
    html = '<div class="buttons">'
    case algorithm.status.to_sym
    when :error, :validation_error, :connection_error
      html << link_to('<em class="fa fa-exclamation-triangle"></em> Recover'.html_safe, recover_algorithm_path(algorithm), method: :post, class: 'btn btn-primary btn-block')
    when :published
      html << link_to('<em class="fa fa-pencil"></em> Edit'.html_safe, algorithm_path(algorithm), class: 'btn btn-primary btn-block')
      html << link_to('<em class="fa fa-trash"></em> Remove'.html_safe, algorithm_path(algorithm), class: 'btn btn-danger btn-block', method: :delete, data: { confirm: 'Are you sure?' })
    when :unpublished_changes
      html << link_to('<em class="fa fa-pencil"></em> Edit'.html_safe, algorithm_path(algorithm), class: 'btn btn-primary btn-block')
      html << link_to('<em class="fa fa-undo"></em> Undo'.html_safe, revert_algorithm_path(algorithm), method: :post, class: 'btn btn-warning btn-block')
      html << link_to('<em class="fa fa-trash"></em> Remove'.html_safe, algorithm_path(algorithm), class: 'btn btn-danger btn-block', method: :delete, data: { confirm: 'Are you sure?' })
    when :validating, :creating, :testing
      html << '<i class="fa fa-refresh fa-spin fa-fw" aria-hidden="true"></i>'.html_safe
    when *Algorithm.wizard_steps
      html << link_to('<em class="fa fa-chevron-circle-right"></em> Continue'.html_safe, algorithm_algorithm_wizard_path(algorithm, algorithm.status), class: 'btn btn-primary btn-block')
      html << link_to('<em class="fa fa-trash"></em> Remove'.html_safe, algorithm_path(algorithm), class: 'btn btn-danger btn-block', method: :delete, data: { confirm: 'Are you sure?' })
    end
    html << '</div>'
    return html.html_safe
  end
end
