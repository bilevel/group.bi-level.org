function _move_toc() {
    // Declare a fragment:
    var fragment = document.createDocumentFragment();
    const collection = document.getElementsByClassName("franklin-toc");
    if (collection.length > 0) {
        // Append desired element to the fragment:
        fragment.appendChild(collection[0]);
        // Append fragment to desired element:
        var sc = document.getElementById('sidebar-content');
        sc.appendChild(fragment);
        sc.parentNode.style.display = "block";
    }

}
document.addEventListener('DOMContentLoaded', function() {
    _move_toc();
}, false);
