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

  def overview_intro_text(sign, current_user)
    return "Hey #{current_user.username}, you are the creator of this sign" if sign.contributor == current_user

    "Hey #{current_user.username}, you are the moderating this sign"
  end
end
