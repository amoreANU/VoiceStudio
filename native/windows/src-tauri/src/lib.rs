// OmniVoice Windows shell: a native window around the OmniVoice web app.
// The window loads http://localhost:5173; override with the --url flag or the
// OMNIVOICESTUDIO_URL environment variable.

fn resolve_url() -> String {
    if let Ok(custom) = std::env::var("OMNIVOICESTUDIO_URL") {
        if !custom.is_empty() {
            return custom;
        }
    }
    for arg in std::env::args().skip(1) {
        if let Some(rest) = arg.strip_prefix("--url=") {
            return rest.to_string();
        }
    }
    "http://localhost:5173".to_string()
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let url = resolve_url();
    tauri::Builder::default()
        .setup(move |app| {
            let parsed: tauri::Url = url.parse()?;
            tauri::WebviewWindowBuilder::new(app, "main", tauri::WebviewUrl::External(parsed))
                .title("OmniVoice")
                .inner_size(1360.0, 860.0)
                .min_inner_size(960.0, 640.0)
                .build()?;
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running OmniVoice");
}
