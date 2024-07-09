// webling photo page
// download selected images

import JSZip from "jszip";
import { saveAs } from "file-saver";

document.addEventListener('turbolinks:load', () => {
  const selectAllCheckbox = document.getElementById('select-all-checkbox');
  const photoCheckboxes = document.querySelectorAll('.photo-checkbox');
  const downloadSelectedBtn = document.getElementById('download-selected-btn');

  if (selectAllCheckbox && photoCheckboxes && downloadSelectedBtn) {
    selectAllCheckbox.addEventListener('change', (e) => {
      const isChecked = e.target.checked;
      photoCheckboxes.forEach(checkbox => {
        checkbox.checked = isChecked;
      });
    });

    downloadSelectedBtn.addEventListener('click', async () => {
      const selectedPhotos = [];
      photoCheckboxes.forEach(checkbox => {
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