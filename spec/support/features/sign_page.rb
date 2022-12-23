class SignPage
  include Capybara::DSL
  attr_reader :sign

  def start(sign = FactoryBot.create(:sign))
    @sign = sign
    visit "/signs/#{@sign.to_param}"
  end

  def breadcrumb(&block)
    within(".breadcrumbs", &block)
  end

  def video_player
    find(".sign-card__media > .video-wrapper > .video")
  end
end
