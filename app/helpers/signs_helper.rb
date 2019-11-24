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

    return link_to_login(add_folder_icon, classes) unless user_signed_in?

    in_folder = sign.available_folders.reject { |_folder, membership| membership.nil? }.any?
    classes << "sign-card__folders__button--in-folder" if in_folder
    button_tag(
      in_folder ? in_folder_icon : add_folder_icon,
      class: classes,
      data: data(sign))
  end

  def sign_show_folder_button(sign)
    classes = %w[button clear medium]

    return link_to_login(sign_show_folder_icon, classes) unless user_signed_in?

    button_tag(
      sign_show_folder_icon,
      class: classes,
      data: data(sign)
    )
  end

  def fetch_folder_button(sign)
    return sign_show_folder_button(sign) if sign_show_folder_button?(sign)

    folder_button(sign)
  end

  def sign_show_folder_button?(sign)
    show_path = "/signs/#{sign.id}"

    return true if request.path == show_path
    return true if request.referer.include?(show_path) && request.path.include?("/folder_memberships")

    false
  end

  def data(sign)
    { toggle: dom_id(sign, :folder_menu) }
  end

  def agree_button(sign, extra_classes="grid-x align-middle", &block)
    classes = "sign-card__votes--agree #{extra_classes}"
    return content_tag(:div, class: classes, &block) unless policy(sign).agree?

    if SignActivity.agree?(sign_id: sign.id, user: current_user)
      classes << " sign-card__votes--agreed"
      return link_to(sign_agreement_path(sign), method: :delete,
                                                data: { remote: true },
                                                title: "Undo agree", class: classes, &block)
    end

    link_to(sign_agreement_path(sign), method: :post,
                                       title: "Agree",
                                       data: { remote: true },
                                       class: classes, &block)
  end

  def disagree_button(sign, extra_classes="grid-x align-middle", &block)
    classes = "sign-card__votes--disagree #{extra_classes}"
    return content_tag(:div, class: classes, &block) unless policy(sign).disagree?

    if SignActivity.disagree?(sign_id: sign.id, user: current_user)
      classes << " sign-card__votes--disagreed"
      return link_to(sign_disagreement_path(sign), title: "Undo disagree",
                                                   data: { remote: true },
                                                   method: :delete, class: classes, &block)
    end

    link_to(sign_disagreement_path(sign), method: :post,
                                          data: { remote: true },
                                          title: "Disagree",
                                          class: classes, &block)
  end

  def in_folder_icon
    inline_svg("media/images/folder-success.svg", title: "Folders", aria: true, class: "icon")
  end

  def add_folder_icon
    inline_svg("media/images/folder-add.svg", title: "Folders", aria: true, class: "icon")
  end

  def overview_reject_link(sign)
    link_to(
      reject_icon,
      reject_path(sign),
      method: :patch,
      data: { confirm: reject_confirm(sign) },
      class: "button alert icon-only overview",
      title: reject_title(sign)
    )
  end

  def reject_path(sign)
    sign.submitted? ? decline_sign_path(sign) : cancel_request_unpublish_sign_path(sign)
  end

  def reject_icon
    inline_svg("media/images/disagree.svg", aria_hidden: true, class: "icon")
  end

  def reject_confirm(sign)
    I18n.t("sign_workflow.#{sign.submitted? ? "decline" : "cancel_request_unpublish"}.confirm")
  end

  def reject_title(sign)
    sign.submitted? ? "Decline" : "Cancel Request"
  end

  def overview_approve_link(sign)
    link_to(
      approve_icon,
      approve_path(sign),
      method: :patch,
      data: { confirm: approve_confirm(sign) },
      class: "button success icon-only overview",
      title: approve_title(sign)
    )
  end

  def approve_path(sign)
    sign.submitted? ? publish_sign_path(sign) : unpublish_sign_path(sign)
  end

  def approve_icon
    inline_svg("media/images/agree.svg", aria_hidden: true, class: "icon")
  end

  def approve_confirm(sign)
    I18n.t("sign_workflow.#{sign.submitted? ? "publish" : "unpublish"}.confirm")
  end

  def approve_title(sign)
    sign.submitted? ? "Publish" : "Make Private"
  end

  def sign_show_folder_icon
    inline_svg("media/images/folder-add.svg", aria: true, class: "icon icon--medium") + "Add to Folder"
  end

  def link_to_login(icon, classes)
    link_to(icon, new_user_session_path, class: classes)
  end
end
