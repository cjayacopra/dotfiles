#!/bin/bash
# Default Applications Helper Script
# Manages default applications using xdg-mime and xdg-settings
# Part of the Noctalia default-apps plugin

set -e

# Color codes for output (when used interactively)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log functions
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }

# Get all desktop file applications from standard locations
get_desktop_files() {
    local dirs=(
        "/usr/share/applications"
        "/usr/local/share/applications"
        "$HOME/.local/share/applications"
    )
    
    # Collect all .desktop files
    local desktop_files=()
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            while IFS= read -r -d '' file; do
                desktop_files+=("$file")
            done < <(find "$dir" -maxdepth 1 -name "*.desktop" -print0 2>/dev/null)
        fi
    done
    
    # Return as JSON array
    printf '%s\n' "$(printf '%s\n' "${desktop_files[@]}" | jq -R . | jq -s .)"
}

# Parse desktop file to get Name, Icon, and Executable
parse_desktop_file() {
    local file="$1"
    local name icon exec_cmd generic_name comment
    
    # Read desktop file entries
    name=$(grep -m1 "^Name=" "$file" 2>/dev/null | cut -d= -f2-)
    generic_name=$(grep -m1 "^GenericName=" "$file" 2>/dev/null | cut -d= -f2-)
    icon=$(grep -m1 "^Icon=" "$file" 2>/dev/null | cut -d= -f2-)
    exec_cmd=$(grep -m1 "^Exec=" "$file" 2>/dev/null | cut -d= -f2- | awk '{print $1}')
    comment=$(grep -m1 "^Comment=" "$file" 2>/dev/null | cut -d= -f2-)
    
    # Use GenericName if Name is not available
    [[ -z "$name" ]] && name="$generic_name"
    [[ -z "$name" ]] && name="$(basename "$file" .desktop)"
    
    # Return as JSON object
    jq -n \
        --arg name "$name" \
        --arg icon "$icon" \
        --arg exec "$exec_cmd" \
        --arg file "$file" \
        --arg comment "$comment" \
        '{name: $name, icon: $icon, executable: $exec, file: $file, comment: $comment}'
}

# Get application details from desktop file
get_app_details() {
    local desktop_file="$1"
    
    if [[ ! -f "$desktop_file" ]]; then
        echo '{"error": "File not found"}'
        return 1
    fi
    
    parse_desktop_file "$desktop_file"
}

# Get all available applications as JSON array
get_all_applications() {
    local apps_json="["
    local first=true
    
    local dirs=(
        "/usr/share/applications"
        "/usr/local/share/applications"
        "$HOME/.local/share/applications"
    )
    
    # Collect all unique .desktop files
    declare -A seen_files
    
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            while IFS= read -r -d '' file; do
                # Skip if NoDisplay=true
                if grep -q "^NoDisplay=true" "$file" 2>/dev/null; then
                    continue
                fi
                
                # Skip duplicates
                local basename_file
                basename_file=$(basename "$file")
                if [[ -n "${seen_files[$basename_file]}" ]]; then
                    continue
                fi
                seen_files[$basename_file]=1
                
                # Get app details
                local app_json
                app_json=$(parse_desktop_file "$file")
                
                if [[ "$first" == true ]]; then
                    first=false
                else
                    apps_json+=","
                fi
                apps_json+="$app_json"
            done < <(find "$dir" -maxdepth 1 -name "*.desktop" -print0 2>/dev/null)
        fi
    done
    
    apps_json+="]"
    echo "$apps_json"
}

# Get current default for a category
get_default_for_category() {
    local category="$1"
    local mime_type=""
    
    # Map category to MIME type
    case "$category" in
        browser)
            mime_type="x-scheme-handler/http"
            ;;
        terminal)
            # Try multiple approaches for terminal
            local term_default
            # Try xdg-mime first
            term_default=$(xdg-mime query default application/x-terminal 2>/dev/null | grep -E '\.desktop$' || true)
            if [[ -n "$term_default" ]] && [[ -f "/usr/share/applications/$term_default" || -f "$HOME/.local/share/applications/$term_default" ]]; then
                parse_desktop_file "$(find /usr/share/applications ~/.local/share/applications -name "$term_default" 2>/dev/null | head -1)"
                return 0
            fi
            # Try xdg-settings
            term_default=$(xdg-settings get default-terminal-emulator 2>/dev/null | grep -E '\.desktop$' || true)
            if [[ -n "$term_default" ]] && [[ "$term_default" != "default" ]]; then
                local full_path
                full_path=$(find /usr/share/applications ~/.local/share/applications -name "$term_default" 2>/dev/null | head -1)
                if [[ -n "$full_path" ]]; then
                    parse_desktop_file "$full_path"
                    return 0
                fi
            fi
            # Try common terminals
            for term in alacritty.desktop kitty.desktop gnome-terminal.desktop konsole.desktop xterm.desktop; do
                for dir in "/usr/share/applications" "/usr/local/share/applications" "$HOME/.local/share/applications"; do
                    if [[ -f "$dir/$term" ]]; then
                        parse_desktop_file "$dir/$term"
                        return 0
                    fi
                done
            done
            parse_desktop_file "/usr/share/applications/kitty.desktop"
            return 0
            ;;
        file-manager)
            mime_type="inode/directory"
            ;;
        email)
            mime_type="x-scheme-handler/mailto"
            ;;
        video)
            mime_type="video/*"
            ;;
        audio)
            mime_type="audio/*"
            ;;
        image)
            mime_type="image/*"
            ;;
        text)
            mime_type="text/plain"
            ;;
        *)
            log_error "Unknown category: $category"
            echo ""
            return 1
            ;;
    esac
    if [[ -n "$mime_type" ]]; then
        local desktop_file
        desktop_file=$(xdg-mime query default "$mime_type" 2>/dev/null | grep -oE '[^/]+\.desktop$' || echo "")
        
        if [[ -n "$desktop_file" ]]; then
            # Find full path
            local full_path=""
            for dir in "/usr/share/applications" "/usr/local/share/applications" "$HOME/.local/share/applications"; do
                if [[ -f "$dir/$desktop_file" ]]; then
                    full_path="$dir/$desktop_file"
                    break
                fi
            done
            
            if [[ -n "$full_path" ]]; then
                parse_desktop_file "$full_path"
            else
                echo "{\"name\": \"$desktop_file\", \"icon\": \"\", \"file\": \"$desktop_file\"}"
            fi
        else
            echo "{\"name\": \"None\", \"icon\": \"\", \"file\": \"\"}"
        fi
    fi
}

# Set default application for a category
set_default_for_category() {
    local category="$1"
    local desktop_file="$2"
    
    if [[ -z "$category" ]] || [[ -z "$desktop_file" ]]; then
        log_error "Usage: set_default_for_category <category> <desktop-file>"
        return 1
    fi
    
    # Validate desktop file exists
    local found=false
    local dirs=(
        "/usr/share/applications"
        "/usr/local/share/applications"
        "$HOME/.local/share/applications"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ -f "$dir/$desktop_file" ]]; then
            found=true
            break
        fi
    done
    
    if [[ "$found" == false ]] && [[ ! -f "$desktop_file" ]]; then
        log_error "Desktop file not found: $desktop_file"
        return 1
    fi
    
    # Map category to MIME type
    local mime_type=""
    case "$category" in
        browser)
            mime_type="x-scheme-handler/http"
            # Also set https
            xdg-mime default "$desktop_file" x-scheme-handler/https 2>/dev/null || true
            ;;
        terminal)
            # Terminal is special - use xdg-mime for application/x-terminal
            # First check if there's a valid desktop file from xdg-mime
            term_default=$(xdg-mime query default application/x-terminal 2>/dev/null | grep -E '\.desktop$' || true)
            if [[ -n "$term_default" ]]; then
                echo "$term_default"
                return 0
            fi
            # Also try xdg-settings if available
            term_default=$(xdg-settings get default-terminal-emulator 2>/dev/null | grep -E '\.desktop$' || true)
            if [[ -n "$term_default" ]]; then
                echo "$term_default"
                return 0
            fi
            # Fallback: check for common terminals in standard locations
            for term in alacritty.desktop kitty.desktop gnome-terminal.desktop konsole.desktop xterm.desktop; do
                for dir in "/usr/share/applications" "/usr/local/share/applications" "$HOME/.local/share/applications"; do
                    if [[ -f "$dir/$term" ]]; then
                        echo "$term"
                        return 0
                    fi
                done
            done
            echo "kitty.desktop"
            return 0
            ;;
        file-manager)
            mime_type="inode/directory"
            ;;
        email)
            mime_type="x-scheme-handler/mailto"
            ;;
        video)
            mime_type="video/*"
            ;;
        audio)
            mime_type="audio/*"
            ;;
        image)
            mime_type="image/*"
            ;;
        text)
            mime_type="text/plain"
            ;;
        *)
            log_error "Unknown category: $category"
            return 1
            ;;
    esac
    
    if [[ -n "$mime_type" ]]; then
        xdg-mime default "$desktop_file" "$mime_type"
        log_info "Set default for $category ($mime_type) to: $desktop_file"
    fi
    
    return 0
}

# Get all categories with their current defaults
get_all_defaults() {
    local categories=("browser" "terminal" "file-manager" "email" "video" "audio" "image" "text")
    local result="["
    local first=true
    
    for cat in "${categories[@]}"; do
        local default_app
        default_app=$(get_default_for_category "$cat")
        
        # Get app details if we have a default
        local app_details
        if [[ -n "$default_app" ]]; then
            local desktop_path=""
            for dir in "/usr/share/applications" "/usr/local/share/applications" "$HOME/.local/share/applications"; do
                if [[ -f "$dir/$default_app" ]]; then
                    desktop_path="$dir/$default_app"
                    break
                fi
            done
            
            if [[ -n "$desktop_path" ]]; then
                app_details=$(parse_desktop_file "$desktop_path")
            else
                app_details=$(jq -n --arg name "$default_app" --arg file "$default_app" '{name: $name, file: $file, icon: "", executable: ""}')
            fi
        else
            app_details=$(jq -n '{name: "None", file: "", icon: "", executable: ""}')
        fi
        
        if [[ "$first" == true ]]; then
            first=false
        else
            result+=","
        fi
        
        result+=$(jq -n \
            --arg category "$cat" \
            --argjson app "$app_details" \
            '{category: $category, default: $app}')
    done
    
    result+="]"
    echo "$result"
}

# Get applications suitable for a specific category
get_applications_for_category() {
    local category="$1"
    
    # Filter applications based on category
    local apps_json="["
    local first=true
    
    local dirs=(
        "/usr/share/applications"
        "/usr/local/share/applications"
        "$HOME/.local/share/applications"
    )
    
    declare -A seen_files
    
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            while IFS= read -r -d '' file; do
                # Skip NoDisplay
                if grep -q "^NoDisplay=true" "$file" 2>/dev/null; then
                    continue
                fi
                
                local basename_file
                basename_file=$(basename "$file")
                if [[ -n "${seen_files[$basename_file]}" ]]; then
                    continue
                fi
                seen_files[$basename_file]=1
                
                # Filter by category - more strict matching
                local should_include=false
                local priority=0
                local app_name comment exec_line categories_line
                app_name=$(grep -m1 "^Name=" "$file" 2>/dev/null | cut -d= -f2- | tr '[:upper:]' '[:lower:]')
                comment=$(grep -m1 "^Comment=" "$file" 2>/dev/null | cut -d= -f2- | tr '[:upper:]' '[:lower:]')
                exec_line=$(grep -m1 "^Exec=" "$file" 2>/dev/null | cut -d= -f2- | tr '[:upper:]' '[:lower:]')
                categories_line=$(grep -m1 "^Categories=" "$file" 2>/dev/null | cut -d= -f2- | tr '[:upper:]' '[:lower:]')
                
                case "$category" in
                    browser)
                        # Check for exact browser names and WebBrowser category
                        if echo "$categories_line" | grep -qE "webbrowser"; then
                            # Exclude if contains "avahi" or "zeroconf" (not a web browser)
                            if ! echo "$app_name" | grep -qE "avahi|zeroconf|vnc|ssh"; then
                                should_include=true; priority=3
                            fi
                        elif echo "$app_name" | grep -qE "^firefox$|^chromium$|^brave$|^vivaldi$|^epiphany$|^librewolf$|^zen$"; then
                            should_include=true; priority=3
                        elif echo "$app_name" | grep -qE "browser$"; then
                            # Ends with browser - likely a web browser
                            if ! echo "$app_name" | grep -qE "avahi|zeroconf|vnc|ssh|network"; then
                                should_include=true; priority=2
                            fi
                        fi
                        ;;
                    terminal)
                        if echo "$categories_line" | grep -qE "terminal|emulator"; then
                            should_include=true; priority=3
                        elif echo "$app_name" | grep -qE "^kitty$|^alacritty$|^gnome-terminal|^konsole$|^xfce4-terminal|^urxvt|^rxvt|^st$|^xterm$|^terminator$|^tilix$|^termite$"; then
                            should_include=true; priority=3
                        elif echo "$app_name" | grep -qE "terminal"; then
                            should_include=true; priority=1
                        fi
                        ;;
                    file-manager)
                        if echo "$categories_line" | grep -qE "filemanager|filesystem"; then
                            # Exclude if it contains settings, screenshot, partition, etc.
                            if ! echo "$app_name" | grep -qE "settings|screenshot|partition|theme|wallpaper"; then
                                should_include=true; priority=3
                            fi
                        elif echo "$app_name" | grep -qE "^nautilus$|^dolphin$|^thunar$|^pcmanfm$|^caja$|^nemo$|^spacefm$|^files$"; then
                            should_include=true; priority=3
                        elif echo "$app_name" | grep -qE " file manager$|^file manager " && ! echo "$app_name" | grep -qE "settings"; then
                            should_include=true; priority=2
                        fi
                        ;;
                    email)
                        if echo "$categories_line" | grep -qE "email|mail"; then
                            should_include=true; priority=3
                        elif echo "$app_name" | grep -qE "^thunderbird|^evolution|^claws.?mail|^geary|^kontact|^trojita"; then
                            should_include=true; priority=3
                        fi
                        ;;
                    video)
                        if echo "$categories_line" | grep -qE "video|player"; then
                            should_include=true; priority=3
                        elif echo "$app_name" | grep -qE "^vlc|^mpv|^mplayer|^totem|^smplayer|^celluloid|^haruna"; then
                            should_include=true; priority=3
                        fi
                        ;;
                    audio)
                        if echo "$categories_line" | grep -qE "audio|music|player"; then
                            should_include=true; priority=3
                        elif echo "$app_name" | grep -qE "^rhythmbox|^audacious|^clementine|^deadbeef|^amarok|^strawberry|^spotify"; then
                            should_include=true; priority=3
                        fi
                        ;;
                    image)
                        if echo "$categories_line" | grep -qE "image|viewer|graphics"; then
                            should_include=true; priority=3
                        elif echo "$app_name" | grep -qE "^gwenview|^eog|^ristretto|^feh|^imv|^sxiv|^viewnior"; then
                            should_include=true; priority=3
                        fi
                        ;;
                    text)
                        if echo "$categories_line" | grep -qE "texteditor|development"; then
                            should_include=true; priority=3
                        elif echo "$app_name" | grep -qE "^gedit|^kate|^mousepad|^pluma|^featherpad|^leafpad|^vim|^emacs|^nano|^code$|^neovim"; then
                            should_include=true; priority=3
                        fi
                        ;;
                esac
                
                # Only include apps that match, no fallback random include
                if [[ "$should_include" == true ]]; then
                    local app_json
                    app_json=$(parse_desktop_file "$file")
                    
                    if [[ "$first" == true ]]; then
                        first=false
                    else
                        apps_json+=","
                    fi
                    
                    # Add priority field
                    apps_json+=$(jq -n \
                        --argjson app "$app_json" \
                        --argjson priority "$priority" \
                        '$app + {priority: $priority}')
                fi
            done < <(find "$dir" -maxdepth 1 -name "*.desktop" -print0 2>/dev/null)
        fi
    done
    
    apps_json+="]"
    
    # Sort by priority (higher first)
    echo "$apps_json" | jq 'sort_by(.priority) | reverse'
}

# Main command handler
case "$1" in
    get-all-applications)
        get_all_applications
        ;;
    get-applications)
        get_applications_for_category "$2"
        ;;
    get-default)
        get_default_for_category "$2"
        ;;
    set-default)
        set_default_for_category "$2" "$3"
        ;;
    get-all-defaults)
        get_all_defaults
        ;;
    get-app-details)
        get_app_details "$2"
        ;;
    *)
        echo "Usage: $0 {get-all-applications|get-applications|get-default|set-default|get-all-defaults|get-app-details} [args...]"
        echo ""
        echo "Commands:"
        echo "  get-all-applications        - Get all available desktop applications"
        echo "  get-applications <category> - Get applications filtered by category"
        echo "  get-default <category>       - Get current default for category"
        echo "  set-default <category> <desktop-file> - Set default for category"
        echo "  get-all-defaults            - Get all category defaults"
        echo "  get-app-details <file>     - Get details for a desktop file"
        exit 1
        ;;
esac
