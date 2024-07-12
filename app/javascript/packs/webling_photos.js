import JSZip from "jszip";
import { saveAs } from "file-saver";

document.addEventListener('turbolinks:load', () => {
  console.log('webling photos loaded');

  const loader = document.getElementById("loader");
  const photosContent = document.getElementById("photos-content");

  function showLoader() {
    loader.style.display = "block";
  }

  function hideLoader() {
    loader.style.display = "none";
  }

  function fetchPhotos() {
    showLoader();
    console.log(window.authToken);
    fetch(`/webling_photos/fetch_files?token=${window.authToken}`)
      .then(response => response.json())
      .then(data => {
        hideLoader();
        displayPhotos(data);
      })
      .catch(error => {
        hideLoader();
        console.error('Error fetching photos:', error);
        alert("Failed to load data. Please try again later.");
      });
  }

  function displayPhotos(subfolders_with_photo_ids) {
    if (subfolders_with_photo_ids.length > 0) {
      let content = "";

      subfolders_with_photo_ids.forEach((subfolder, idx) => {
        content += `
          <ul class="collapsible">
            <li>
              <div class="collapsible-header action-items">
                <h2>${subfolder.title}</h2>
                <p class="left-padding">
                  <label>
                    <input type="checkbox" class="filled-in select-all-checkbox" id="select-all-checkbox-${idx}" data-index="${idx}">
                    <span>Alle auswählen</span>
                  </label>
                </p>
              </div>
              <div class="collapsible-body">
                <div class="row">
                  <ul class="photo-elements">`;

        if (subfolder.photo_objects.length > 0) {
          subfolder.photo_objects.forEach(photo => {
            const full_file_content = `/webling_photos/${photo.id}?token=${window.authToken}`; // Adjust the path
            const thumbnail_content = `/webling_photos/${photo.id}/thumbnail?token=${window.authToken}`; // Adjust the path
            const file_name = photo.data.properties.file.name;
            const file_type = file_name.split('.').pop();

            content += `
              <li class="col s12 m3 custom-li">
                <div class="card medium hoverable custom-card">
                  <div class="card-image">
                    <img src="${thumbnail_content}" alt="${file_name}" class="responsive-img materialboxed">
                    ${file_type === 'mp4' ? '<div class="video-overlay"><span class="play-icon">▶</span></div>' : ''}
                  </div>
                  <div class="card-content">
                    ${file_name}
                    <div class="card-action">
                      <p>
                        <label>
                          <input type="checkbox" class="filled-in photo-checkbox" data-index="${idx}" value="${full_file_content}">
                          <span>Auswählen</span>
                        </label>
                        <a href="${full_file_content}" target="_blank" class="waves-effect waves-light btn">↗ Originalgröße</a>
                      </p>
                    </div>
                  </div>
                </div>
              </li>`;
          });
        } else {
          content += `<p>Leerer Ordner</p>`;
        }

        content += `</ul></div></li></ul>`;
      });

      photosContent.innerHTML = content;
    } else {
      photosContent.innerHTML = "<p>Keine Fotos verfügbar</p>";
    }
  }

  // Fetch photos when the page loads
  fetchPhotos();


  // Checkboxes for photo selection
  const selectAllCheckboxes = document.querySelectorAll('.select-all-checkbox');
  const downloadSelectedBtn = document.getElementById('download-selected-btn');

  if (selectAllCheckboxes && downloadSelectedBtn) {
    selectAllCheckboxes.forEach(selectAllCheckbox => {
      selectAllCheckbox.addEventListener('change', (e) => {
        const idx = e.target.dataset.index;
        const isChecked = e.target.checked;
        const photoCheckboxes = document.querySelectorAll(`.photo-checkbox[data-index='${idx}']`);

        photoCheckboxes.forEach(checkbox => {
          checkbox.checked = isChecked;
        });
      });
    });

    downloadSelectedBtn.addEventListener('click', async () => {
      const selectedPhotos = [];

      document.querySelectorAll('.photo-checkbox').forEach(checkbox => {
        if (checkbox.checked) {
          selectedPhotos.push(checkbox.value);
        }
      });

      if (selectedPhotos.length > 0) {
        const zip = new JSZip();
        const folder = zip.folder("photos");

        for (const photoUrl of selectedPhotos) {
          const response = await fetch(photoUrl);
          const blob = await response.blob();
          const fileName = photoUrl.split('/').pop().split('?')[0] + '.jpg';
          folder.file(fileName, blob);
        }

        const content = await zip.generateAsync({ type: "blob" });
        saveAs(content, "photos.zip");
      } else {
        alert('No photos selected for download');
      }
    });
  }
});




