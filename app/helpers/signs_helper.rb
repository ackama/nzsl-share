module SignsHelper
  def agree_button(sign, extra_classes = "grid-x align-middle", table: false, &block)
    classes = "sign-#{table ? "table" : "card"}__controls--agree #{extra_classes}"
    return content_tag(:div, id: dom_id(sign, :agree_button), class: classes, &block) unless policy(sign).agree?

    if SignActivity.agree?(sign_id: sign.id, user: current_user)
      classes << " sign-card__controls--agreed"
      return undo_agree_button(sign, classes, &block)
    end

    link_to(sign_agreement_path(sign), method: :post,
                                       id: dom_id(sign, :agree_button),
                                       title: "Agree",
                                       data: { remote: true },
                                       class: classes, &block)
  end

  def disagree_button(sign, extra_classes = "grid-x align-middle", table: false, &block)
    classes = "sign-#{table ? "table" : "card"}__controls--disagree #{extra_classes}"
    return content_tag(:div, class: classes, &block) unless policy(sign).disagree?

    if SignActivity.disagree?(sign_id: sign.id, user: current_user)
      classes << " sign-card__controls--disagreed"
      return undo_disagree_button(sign, classes, &block)
    end

    link_to(sign_disagreement_path(sign), method: :post,
                                          data: { remote: true },
                                          title: "Disagree",
                                          class: classes, &block)
  end

  def undo_agree_button(sign, classes, &block)
    link_to(sign_agreement_path(sign), method: :delete,
                                       data: { remote: true },
                                       title: "Undo agree",
                                       class: classes, &block)
  end

  def undo_disagree_button(sign, classes, &block)
    link_to(sign_disagreement_path(sign), title: "Undo disagree",
                                          data: { remote: true },
                                          method: :delete, class: classes, &block)
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

  def folder_selection(sign)
    folders = policy_scope(sign.folders).map { |f| [f.title, f.id] }
    folders << ["Public", nil] if sign.published? || sign.unpublish_requested?
    folders.reverse
  end

  def reject_path(sign)
    sign.submitted? ? decline_sign_path(sign) : cancel_request_unpublish_sign_path(sign)
  end

  def reject_icon
    inline_svg_pack_tag("media/images/disagree.svg", aria_hidden: true, class: "icon")
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
    inline_svg_pack_tag("media/images/agree.svg", aria_hidden: true, class: "icon")
  end

  def approve_confirm(sign)
    I18n.t("sign_workflow.#{sign.submitted? ? "publish" : "unpublish"}.confirm")
  end

  def approve_title(sign)
    sign.submitted? ? "Publish" : "Make Private"
  end
end
