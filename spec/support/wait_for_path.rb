module WaitForPath
  def wait_for_path(path=nil)
    original_path = current_path
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until path.nil? ? path_changed?(original_path) : reached_path?(path)
    end
  end

  def path_changed?(path)
    current_path != path
  end

  def reached_path?(path)
    current_path == path
  end
end
