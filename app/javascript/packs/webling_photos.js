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

    downloadSelectedBtn.addEventListener('click', () => {
      const selectedPhotos = [];
      photoCheckboxes.forEach(checkbox => {
        if (checkbox.checked) {
          selectedPhotos.push(checkbox.value);
        }
      });

      if (selectedPhotos.length > 0) {
        selectedPhotos.forEach(photoUrl => {
          const a = document.createElement('a');
          a.href = photoUrl;
          a.download = true;
          document.body.appendChild(a);
          a.click();
          document.body.removeChild(a);
        });
      } else {
        alert('No photos selected for download');
      }
    });
  }
});