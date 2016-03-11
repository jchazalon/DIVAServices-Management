module AlgorithmWizardHelper

  def progress_bar(current_step)
    names = ['General Information', 'Input/Output', 'Detailed Input', 'Upload', 'Review']
    icons = ['fa fa-info', 'fa fa-exchange', 'fa fa-list', 'fa fa-upload', 'fa fa-eye']

    content_tag(:div, class: 'wizard') do
      content_tag(:div, class: 'wizard-inner') do
        content_tag(:div, class: 'connecting-line') do
        end +
        content_tag(:ul, class: 'nav nav-tabs', role: 'tablist') do
          (1..(Algorithm.steps.size)).collect do |step|
            concat progress_icon(names[step - 1], icons[step - 1], step == current_step)
          end
        end
      end
    end
  end

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
end
