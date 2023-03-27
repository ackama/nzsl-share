module Admin
  class UsersController < Admin::ApplicationController
    helper RolesHelper
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #
    # def update
    #   foo = Foo.find(params[:id])
    #   foo.update(params[:foo])
    #   send_foo_updated_email
    # end

    def destroy
      DeleteUserJob.perform_now(requested_resource)
      redirect_to admin_users_path, notice: translate_with_resource("destroy.success")
    end

    # Override this method to specify custom lookup behavior.
    # This will be used to set the resource for the `show`, `edit`, and `update`
    # actions.
    #
    # def find_resource(param)
    #   Foo.find_by!(slug: param)
    # end

    # Override this if you have certain roles that require a subset
    # this will be used to set the records shown on the `index` action.
    #
    def scoped_resource
      return super if params[:search].present?
      # Unconfirmed users can be deleted, but are otherwise not included when administering users
      # We include them during destroy so that they can be found to be destroyed.
      return resource_class if action_name == "destroy"

      resource_class.confirmed
    end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
