module SignsHelper
  include Pundit

  ##
  # Determine what kind of button to display to the user:
  #
  #  1. Given user does not have access to add to folders - user may be signed in or not
  #     if the sign does not have permission to be added to a folder, then we do not render
  #     anything.
  #  2. User is not signed in but the sign can be added to folders, render a link to the sign
  #     in page, that has all the necessary classes to look like the 'add to folder' button.
  #  3. Render the normal 'add to folder' button that opens a dropdown menu
  #  4. Render a modifier 'add to folder' button that opens a dropdown menu but has a different visual
  #     appearance to indicate the sign is already in the folder.
  def folder_button(sign)
    return unless policy(sign).manage_folders?
    return folder_sign_in_link unless user_signed_in?

    classes = %w[sign-card__folders__button]
    in_folder = sign.available_folders.reject { |_folder, membership| membership.nil? }.any?
    classes << "sign-card__folders__button--in-folder" if in_folder

    button_tag(
      in_folder ? in_folder_icon : add_folder_icon,
      class: classes,
      data: { toggle: dom_id(sign, :folder_menu) })
  end

  def folder_sign_in_link
    link_to(add_folder_icon, new_user_session_path, class: %w[sign-card__folders__button])
  end

  def in_folder_icon
    inline_svg("media/images/folder-success.svg", title: "Folders", aria: true, class: "icon")
  end

  def add_folder_icon
    inline_svg("media/images/folder-add.svg", title: "Folders", aria: true, class: "icon")
  end
end
