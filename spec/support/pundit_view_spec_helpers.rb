module PunditViewSpecHelper
  def stub_authorization(record = any_args, permissions = {})
    # Pundit#policy is a controller helper, so while we can safely
    # mock it, we cannot verify the mock on the view, since it does
    # not have controller methods mixed in
    without_partial_double_verification do
      policy = double(permissions).as_null_object
      allow(view).to receive(:policy).with(record).and_return(policy)
    end
  end

  def stub_policy_scope(scope)
    # Pundit#policy_scope is a controller helper, so while we can safely
    # mock it, we cannot verify the mock on the view, since it does
    # not have controller methods mixed in
    without_partial_double_verification do
      allow(view).to receive(:policy_scope).with(scope).and_return(scope)
    end
  end

  # Use to mock out when an auth flow uses a specific policy type not automatically
  # associated with the model type passed in.
  # Calls in prod code typically look like:
  # authorize @application, policy_class: ListingApplicationNotePolicy
  def stub_policy_authorization(policy_class, **permissions)
    permissions.each do |permission, authorized|
      # Pundit#policy is a controller helper, so while we can safely
      # mock it, we cannot verify the mock on the view, since it does
      # not have controller methods mixed in
      without_partial_double_verification do
        base = allow(view).to receive(:authorize).with(anything, "#{permission}?", policy_class:)
        base.and_raise NotAuthorizedError unless authorized
      end
    end
  end
end
