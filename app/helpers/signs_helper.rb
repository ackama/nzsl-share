module SignsHelper
  ##
  # Determine what kind of button to display to the user:
  #
  #  1. User is not signed. Render a link to the sign in page, that has all the necessary classes to
  #     look like the 'add to folder' button.
  #  2. Render the normal 'add to folder' button that opens a dropdown menu
  #  3. Render a modifier 'add to folder' button that opens a dropdown menu but has a different visual
  #     appearance to indicate the sign is already in the folder.
  def folder_button(sign)
    classes = %w[sign-card__folders__button]
    return link_to(add_folder_icon, new_user_session_path, class: classes) unless user_signed_in?

    in_folder = sign.available_folders.reject { |_folder, membership| membership.nil? }.any?
    classes << "sign-card__folders__button--in-folder" if in_folder
    button_tag(
      in_folder ? in_folder_icon : add_folder_icon,
      class: classes,
      data: { toggle: dom_id(sign, :folder_menu) })
  end

  def in_folder_icon
    inline_svg("media/images/folder-success.svg", title: "Folders", aria: true, class: "icon")
  end

  def add_folder_icon
    inline_svg("media/images/folder-add.svg", title: "Folders", aria: true, class: "icon")
  end

  def overview_decline_link(sign)
    link_to(
      decline_icon,
      decline_path(sign),
      method: :patch,
      data: { confirm: decline_confirm(sign) },
      class: "button alert icon-only"
    )
  end

  def decline_path(sign)
    sign.submitted? ? decline_sign_path(sign) : cancel_request_unpublish_sign_path(sign)
  end

  def decline_icon
    inline_svg("media/images/disagree.svg", aria_hidden: true, class: "icon", title: "Decline")
  end

  def decline_confirm(sign)
    I18n.t("sign_workflow.#{sign.submitted? ? "decline" : "cancel_request_unpublish"}.confirm")
  end

  def overview_approve_link(sign)
    link_to(
      approve_icon,
      approve_path(sign),
      method: :patch,
      data: { confirm: approve_confirm(sign) },
      class: "button success icon-only"
    )
  end

  def approve_path(sign)
    sign.submitted? ? publish_sign_path(sign) : unpublish_sign_path(sign)
  end

  def approve_icon
    inline_svg("media/images/agree.svg", aria_hidden: true, class: "icon", title: "Approve")
  end

  def approve_confirm(sign)
    I18n.t("sign_workflow.#{sign.submitted? ? "publish" : "unpublish"}.confirm")
  end
end
