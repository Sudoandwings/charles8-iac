function showPreview(projectNumber) {
    const previewContainer = document.getElementById("preview-container");
    const projectDescription = document.getElementById("project-description");

    // Set up slideshow and description based on projectNumber
    projectDescription.textContent = `Description of Project ${projectNumber}`;
    previewContainer.style.display = "block";
}

function closePreview() {
    document.getElementById("preview-container").style.display = "none";
}
