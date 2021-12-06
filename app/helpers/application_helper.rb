module ApplicationHelper
  def media_manipulation_helper(media:, section_name:)
    return unless signed_in?
    if media
      [
        show_content_actions(media),
        simple_format(media&.content)
      ].join(' ').html_safe
    else
      new_content_link_helper(section_name)
    end
  end

  private

  def show_content_actions(page)
    if signed_in?
      button_types(page)
    end
  end

  def upload_image_helper(page)
    link_to "<i class='material-icons'>add</i>".html_safe, new_image_path(page: page), class: 'btn-floating waves-effect waves-light red'
  end

  def new_content_link_helper(page)
    (link_to 'Neu', new_content_path(page: page), class: 'waves-effect waves-teal btn-flat red btn-small white-text').html_safe
  end

  def button_types(page)
    [
      (link_to 'Bearbeiten', edit_content_path(page), class: 'waves-effect waves-teal btn-flat red btn-small white-text'),
      (link_to 'Löschen', content_path(page), method: :delete, class: 'waves-effect waves-teal btn-flat red btn-small white-text', data: { confirm: 'Bist du sicher, dass du den Text löschen möchtest?'})
    ].join(' ').html_safe
  end
end
