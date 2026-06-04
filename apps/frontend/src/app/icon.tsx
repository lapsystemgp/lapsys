import { ImageResponse } from "next/og";

export const size = { width: 32, height: 32 };
export const contentType = "image/png";

export default function Icon() {
  return new ImageResponse(
    (
      <div
        style={{
          width: 32,
          height: 32,
          background: "#2563EB",
          borderRadius: 8,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        <svg
          width="20"
          height="20"
          viewBox="0 0 24 24"
          fill="none"
          stroke="white"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          {/* Flask / conical flask shape */}
          <path d="M14 2v6l3.5 7a4 4 0 0 1-7 0L14 8V2" />
          <path d="M8.5 2h7" />
          <path d="M7 16h10" />
        </svg>
      </div>
    ),
    { ...size }
  );
}
