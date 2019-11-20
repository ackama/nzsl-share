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
end
