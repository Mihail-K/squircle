module Bannable
  extend ActiveSupport::Concern

  included do
    before_action :check_ban_state, only: %i(create update destroy)
  end

private

  def check_ban_state
    # TODO : Serve an error message.
    forbid if current_user.try(:banned?)
  end
end
