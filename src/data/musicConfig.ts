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
    id:     "track-01",
    title:  "Dark Italian",
    artist: "Genisys Studio",
    src:    "/music/vibe.mp3",
    accent: "#C8A84B",
  },
  {
    id:     "track-02",
    title:  "Adonai",
    artist: "Genisys Studio",
    src:    "/music/Adonai .mp3",
    accent: "#8B5CF6",
  },
  {
    id:     "track-03",
    title:  "Armor on My Chest",
    artist: "Genisys Studio",
    src:    "/music/Armor_on_My_Chest.mp3",
    accent: "#EF4444",
  },
  {
    id:     "track-04",
    title:  "Heart of Steel",
    artist: "Genisys Studio",
    src:    "/music/Heart of Steel (2).mp3",
    accent: "#3B82F6",
  },
  {
    id:     "track-05",
    title:  "Hybrid",
    artist: "Genisys Studio",
    src:    "/music/Hybrid .mp3",
    accent: "#10B981",
  },
  {
    id:     "track-06",
    title:  "March of the Ancient Night",
    artist: "Genisys Studio",
    src:    "/music/March of the Ancient Night (Cover) (1).mp3",
    accent: "#F59E0B",
  },
  {
    id:     "track-07",
    title:  "The Heaven's Choir",
    artist: "Genisys Studio",
    src:    "/music/The Heaven's Choir (1).mp3",
    accent: "#EC4899",
  },
  {
    id:     "track-08",
    title:  "The Special Forces",
    artist: "Genisys Studio",
    src:    "/music/The Special Forces.mp3",
    accent: "#6366F1",
  },
  {
    id:     "track-09",
    title:  "UHC",
    artist: "Genisys Studio",
    src:    "/music/UHC (Cover).mp3",
    accent: "#14B8A6",
  },
  {
    id:     "track-10",
    title:  "Unbreakable",
    artist: "Genisys Studio",
    src:    "/music/Unbreakable.mp3",
    accent: "#EAB308",
  },
];
