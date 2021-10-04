module ApplicationHelper
  def show_content_actions(page)
    if signed_in?
      button_types(page).join(' ').html_safe
    end
  end

  private

  def button_types(page)
    if Content.find_by(page: page)
      (link_to 'new', new_content_path, class: 'waves-effect waves-light btn-small')
    else
      [
        (link_to 'edit', edit_content_path(page), class: 'waves-effect waves-light btn-small'),
        (link_to 'delete', content_path(page), method: :delete, class: 'waves-effect waves-light btn-small')
      ]
    end
  end
end
