module FileUploads
  def drop_file_in_file_upload(path=default_attachment_path, selector: nil, content_type: "video/mp4")
    # If we're using JS, we can drop onto the file upload component
    # Otherwise, we need to specifically select the file
    return choose_file(path) if Capybara.current_driver == :rack_test

    page.driver.execute_script(
      <<-JS
        dt = new DataTransfer();
        evt = jQuery.Event('drop', {
          preventDefault: function () {},
          stopPropagation: function () {},
          originalEvent: {
            dataTransfer: dt,
          }
        })
        dt.items.add(
          new File(
            ['foo'],
            'filenamme',
            {type: "#{content_type}"}
          )
        )
        $("#{selector}.file-upload").trigger(evt)
      JS
    )

    wait_for_ajax
  end

  def choose_file(path=default_attachment_path)
    page.attach_file("Browse files", path)
  end

  def default_attachment_path
    Rails.root.join("spec", "fixtures", "dummy.mp4")
  end
end
