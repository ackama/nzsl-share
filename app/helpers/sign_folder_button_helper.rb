module SignFolderButtonHelper
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

    in_folder = in_folder?(sign)
    classes << "sign-card__folders__button--in-folder" if in_folder
    icon = in_folder ? in_folder_icon : add_folder_icon
    button_tag(icon, class: classes, data: { toggle: dom_id(sign, :folder_menu) })
  end

  def sign_show_folder_button(sign)
    classes = %w[button clear sign-card__folders__button--text-color]

    return link_to_login(add_sign_show_folder_icon, classes) unless user_signed_in?

    in_folder = in_folder?(sign)
    classes << "sign-card__folders__button--in-folder-for-show" if in_folder
    icon = in_folder ? in_sign_show_folder_icon : add_sign_show_folder_icon
    link_to(icon, "#", class: classes, data: { toggle: dom_id(sign, :folder_menu) })
  end

  def fetch_folder_button(sign)
    return sign_show_folder_button(sign) if sign_show_folder_button?(sign)

    folder_button(sign)
  end

  def sign_show_folder_button?(sign)
    return true if request.path.include?(sign_path(sign)) # show for sign and share
    return true if from_sign_show?(sign)

    false
  end

  def from_sign_show?(sign)
    request.referer.present? &&
      request.referer.include?(sign_path(sign)) &&
      request.path.include?("/folder_memberships")
  end

  def in_folder?(sign)
    sign.available_folders.compact.any?
  end

  def in_folder_icon
    inline_svg_pack_tag("static/images/folder-success.svg", title: "Folders", aria: true, class: "icon")
  end

  def add_folder_icon
    inline_svg_pack_tag("static/images/folder-add.svg", title: "Folders", aria: true, class: "icon")
  end

  def in_sign_show_folder_icon
    icon = inline_svg_pack_tag("static/images/folder-success.svg", aria: true, class: "icon icon--medium")

    raw "#{icon}Add to Folder" # rubocop:disable Rails/OutputSafety
  end

  def add_sign_show_folder_icon
    icon = inline_svg_pack_tag("static/images/folder-add.svg", aria: true, class: "icon icon--medium")

    raw "#{icon}Add to Folder" # rubocop:disable Rails/OutputSafety
  end

  def link_to_login(icon, classes)
    link_to(icon, new_user_session_path, class: classes)
  end
end
