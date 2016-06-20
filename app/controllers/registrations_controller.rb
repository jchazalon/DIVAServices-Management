##
# Overwrites the default Devise::RegistrationsController.
class RegistrationsController < Devise::RegistrationsController

  ##
  # Overwrite the create method to enable the use of recaptcha on registrations.
  # More information can be found {here}[https://github.com/plataformatec/devise/wiki/How-To:-Use-Recaptcha-with-Devise].
  def create
    if verify_recaptcha
      super
    else
      build_resource(sign_up_params)
      clean_up_passwords(resource)
      flash.now[:alert] = t('errors.messages.recaptcha')
      flash.delete :recaptcha_error
      render :new
    end
  end
end
