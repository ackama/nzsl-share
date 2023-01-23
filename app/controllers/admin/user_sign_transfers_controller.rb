module Admin
  class UserSignTransfersController < Admin::ApplicationController
    def new
      old_owner
    end

    def create
      SignOwnershipTransferService.new.transfer_sign(old_owner: old_owner, new_owner: new_owner)

      redirect_to admin_user_path(old_owner), notice: t(".success")
    end

    private

    def user_sign_transfer_params
      params.permit(:old_owner, :new_owner)
    end

    def old_owner
      @old_owner ||= User.find(user_sign_transfer_params[:old_owner])
    end

    def new_owner
      @new_owner ||= User.find(user_sign_transfer_params[:new_owner])
    end
  end
end
