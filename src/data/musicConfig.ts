// =============================================================================
//  GENISYS MUSIC CONFIG
//  Add as many songs as you want here.
//
//  HOW TO ADD A SONG:
//    1. Drop the MP3 (or OGG/WAV) into the /public/music/ folder
//    2. Copy one of the objects in PLAYLIST and fill in the details.
//    3. Save. Done. The player picks it up automatically.
// =============================================================================

export interface Track {
  /** Unique ID — any short string, no spaces */
  id:      string;
  /** Track title shown in the player */
  title:   string;
  /** Artist / label shown under the title */
  artist:  string;
  /**
   * Path to the audio file, relative to /public
   * Examples:
   * "/music/vibe.mp3"         ← file is at public/music/vibe.mp3
   */
  src:     string;
  /**
   * Hex accent colour shown on the playlist icon for this track.
   * Defaults to gold if omitted.
   */
  accent?: string;
}

// ─── ADD YOUR SONGS BELOW ────────────────────────────────────────────────────
export const PLAYLIST: Track[] = [
  {
    id:     "vibe-01",
    title:  "Dark Italian",
    artist: "Genisys Studio",
    src:    "/music/vibe.mp3",          // ← EDITED PATH
    accent: "#C8A84B",
  },

  // Uncomment and edit to add more tracks:
  // {
  //   id:     "vibe-02",
  //   title:  "Phantom Pulse",
  //   artist: "Genisys Studio",
  //   src:    "/music/phantom-pulse.mp3",
  //   accent: "#8B5CF6",
  // },
  // {
  //   id:     "vibe-03",
  //   title:  "Iron Frequency",
  //   artist: "Genisys Studio",
  //   src:    "/music/iron-frequency.mp3",
  //   accent: "#EF4444",
  // },
];
