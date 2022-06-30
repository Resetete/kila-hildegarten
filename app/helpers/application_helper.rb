module ApplicationHelper
  def media_manipulation_helper(media:, section_name:)
    if media
      [
        show_content_actions(media),
        simple_format(media&.content)
      ].join(' ').html_safe
    else
      new_content_link_helper(section_name) if signed_in?
    end
  end

  def team_member_action_buttons(team_member)
    if signed_in?
      tag.div(class: 'card-action') do
        [
          (link_to "<i class='material-icons'>edit</i>".html_safe, edit_team_member_path(team_member), class: 'btn-floating waves-effect waves-light red', title: 'Neues Teammitglied hinzufügen'),
          (link_to "<i class='material-icons'>delete</i>".html_safe, team_member_path(team_member), method: :delete, class: 'btn-floating waves-effect waves-light red', data: { confirm: 'Bist du sicher, dass du das Teammitglied löschen möchtest?'}),
        ].join(' ').html_safe
      end
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

  def add_room_plan_details(room_name:, orientation:)
    [
      tag.div(class: 'camera-icon', id: "#{room_name}-icon") do
        fa_icon('camera-retro')
      end,
      image_tag("other_images/room-plan-details/#{room_name}.jpg", class: "detail-photo-#{orientation}", id: "#{room_name}-detail-photo")
    ].join.html_safe
  end
end
