module AlgorithmWizardHelper

  ##
  # Renders the progress bar used in the wizard.
  def progress_bar(current_step)
    names = ['General Information', 'Input', 'Detailed Input', 'Output', 'Detailed Output', 'Upload', 'Review']
    icons = ['fa fa-info', 'fa fa-long-arrow-right', 'fa fa-list', 'fa fa-long-arrow-left', 'fa fa-list', 'fa fa-upload', 'fa fa-eye']

    content_tag(:div, class: 'wizard') do
      content_tag(:div, class: 'wizard-inner') do
        content_tag(:div, class: 'connecting-line') do
        end +
        content_tag(:ul, class: 'nav nav-tabs', role: 'tablist') do
          (1..(Algorithm.wizard_steps.size)).collect do |step|
            concat progress_icon(names[step - 1], icons[step - 1], step == current_step)
          end
        end
      end
    end
  end

  ##
  # Renders an icon used in the progress bar.
  def progress_icon(name, icon, active)
    content_tag(:li, role: 'presentation', class: (active ? 'active' : '')) do
      content_tag(:a, role: 'tab', title: name) do
        content_tag(:span, class: 'round-tab') do
          content_tag(:i, class: icon) do
          end
        end
      end
    end
  end

  ##
  # Returns the humanized (aka pretty) value of the given field.
  def humanize_value(field)
    case field.type
    when 'EnumField'
      field.keys[field.values.index(field.value)]
    else
      field.value
    end
  end
end
