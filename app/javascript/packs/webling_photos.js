import JSZip from "jszip";
import { saveAs } from "file-saver";

document.addEventListener('turbolinks:load', () => {
  console.log('webling photos loaded');
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




