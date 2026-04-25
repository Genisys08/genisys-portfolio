import { useEffect, useState } from "react";

export type Route =
  | { page: "home" }
  | { page: "services" }
  | { page: "studio" }
  | { page: "case-study"; id: string }
  | { page: "not-found" };

// Module-level pending scroll — set before navigating home
let _pendingScroll: string | null = null;

export function consumePendingScroll(): string | null {
  const s = _pendingScroll;
  _pendingScroll = null;
  return s;
}

function parseHash(hash: string): Route {
  // Pages are prefixed with #/ — anything else is a section scroll on home
  if (!hash || hash === "#" || hash === "#/" || !hash.startsWith("#/")) {
    return { page: "home" };
  }
  const path = hash.slice(2); // strip #/
  if (path === "services")         return { page: "services" };
  if (path === "studio")           return { page: "studio" };
  if (path.startsWith("work/"))    return { page: "case-study", id: path.slice(5) };
  return { page: "not-found" };
}

export function useRouter(): Route {
  const [route, setRoute] = useState<Route>(() => parseHash(window.location.hash));
  useEffect(() => {
    const handler = () => setRoute(parseHash(window.location.hash));
    window.addEventListener("hashchange", handler);
    return () => window.removeEventListener("hashchange", handler);
  }, []);
  return route;
}

/** Navigate to a page route */
export function navigatePage(path: string) {
  window.location.hash = `#/${path}`;
  window.scrollTo({ top: 0 });
}

/** Navigate to home then scroll to a section */
export function navigateSection(sectionId: string) {
  _pendingScroll = sectionId;
  if (parseHash(window.location.hash).page !== "home") {
    window.location.hash = "#";
    window.scrollTo({ top: 0 });
  } else {
    setTimeout(() => {
      document.getElementById(sectionId)?.scrollIntoView({ behavior: "smooth" });
    }, 60);
    _pendingScroll = null;
  }
}
