import { saveAs } from "file-saver";

document.addEventListener('turbolinks:load', () => {
  console.log("Webling photos JS loaded");

  // --- Select all checkboxes logic ---
  const selectAllCheckboxes = document.querySelectorAll('.select-all-checkbox');
  selectAllCheckboxes.forEach(selectAll => {
    selectAll.addEventListener('change', e => {
      const idx = e.target.dataset.index;
      const isChecked = e.target.checked;
      const checkboxes = document.querySelectorAll(`.photo-checkbox[data-index='${idx}']`);
      checkboxes.forEach(cb => {
        cb.checked = isChecked;
      });
    });
  });

  // --- Download selected logic ---
  const downloadBtn = document.getElementById('download-selected-btn');
  if (!downloadBtn) return;

  downloadBtn.addEventListener('click', async () => {
    const selected = Array.from(document.querySelectorAll('.photo-checkbox'))
      .filter(cb => cb.checked)
      .map(cb => cb.dataset.photoId);

    if (selected.length === 0) {
      alert('No photos selected for download');
      return;
    }

    const token = document.querySelector('meta[name="webling-token"]')?.content;
    if (!token) {
      alert('Missing authentication token – please reload the page.');
      return;
    }

    try {
      const response = await fetch(`/webling_photos/zip_download?token=${token}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ids: selected })
      });

      if (!response.ok) throw new Error(`Download failed (${response.status})`);

      const blob = await response.blob();
      saveAs(blob, 'photos.zip');
    } catch (error) {
      console.error('ZIP download error:', error);
      alert('Download failed – please try again.');
    }
  });
});
