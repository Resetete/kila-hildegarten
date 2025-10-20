import { saveAs } from "file-saver";

document.addEventListener('turbolinks:load', () => {
  const downloadBtn = document.getElementById('download-selected-btn');

  if (!downloadBtn) return;

  downloadBtn.addEventListener('click', async () => {
    const selected = Array.from(document.querySelectorAll('.photo-checkbox'))
      .filter(cb => cb.checked)
      .map(cb => cb.dataset.photoId || cb.value);

    if (selected.length === 0) {
      alert('No photos selected for download');
      return;
    }

    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

    const response = await fetch('/webling_photos/zip_download', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      credentials: 'include',
      body: JSON.stringify({ ids: selected })
    });

    if (!response.ok) {
      alert('Download failed');
      return;
    }

    const blob = await response.blob();
    saveAs(blob, 'photos.zip');
  });
});
