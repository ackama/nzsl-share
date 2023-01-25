module FileUploads
  def drop_file_in_file_upload(path = default_attachment_path, selector: nil)
    # If we're using JS, we can drop onto the file upload component
    # Otherwise, we need to specifically select the file
    return choose_file(path) if Capybara.current_driver == :rack_test

    find("#{selector}.file-upload").drop(path)
  end

  def choose_file(path = default_attachment_path)
    page.attach_file("Browse files", path)
  end

  def default_attachment_path
    Rails.root.join("spec/fixtures/dummy.mp4")
  end
end
