(() => {
  const millimetresPerPixel = 25.4 / 96;
  const minimumFooterClearanceMm = 4.5;

  const audit = async () => {
    await document.fonts.ready;

    for (const page of document.querySelectorAll(".page")) {
      const footer = page.querySelector(".page-footer");
      const contentBoxes = page.querySelectorAll(
        ".page-grid .panel, .page-grid .experience, .page-grid .capability-block"
      );

      if (!footer || contentBoxes.length === 0) {
        page.dataset.footerSafe = "false";
        page.dataset.footerClearanceMm = "missing";
        continue;
      }

      const contentBottom = Math.max(
        ...Array.from(contentBoxes, (box) => box.getBoundingClientRect().bottom)
      );
      const clearanceMm =
        (footer.getBoundingClientRect().top - contentBottom) * millimetresPerPixel;

      page.dataset.footerClearanceMm = clearanceMm.toFixed(2);
      page.dataset.footerSafe = String(clearanceMm >= minimumFooterClearanceMm);
    }

    document.documentElement.dataset.layoutAudit = "complete";
  };

  audit();
})();
