module AlgorithmWizardHelper

  def progress_bar(step)
    '<div class="wizard">
      <div class="wizard-inner">
        <div class="connecting-line"></div>
        <ul class="nav nav-tabs" role="tablist">
          <li role="presentation">
            <a role="tab" title="Information">
              <span class="round-tab">
                <i class="fa fa-info"></i>
              </span>
            </a>
          </li>

          <li role="presentation" class="active">
            <a role="tab" title="Input/Output">
              <span class="round-tab">
                <i class="fa fa-exchange"></i>
              </span>
            </a>
          </li>
          <li role="presentation" class="disabled">
            <a role="tab" title="Details">
              <span class="round-tab">
                <i class="fa fa-list"></i>
              </span>
            </a>
          </li>

          <li role="presentation" class="disabled">
            <a role="tab" title="Upload">
              <span class="round-tab">
                <i class="fa fa-upload"></i>
              </span>
            </a>
          </li>
        </ul>
      </div>
    </div>'.html_safe
  end

end
