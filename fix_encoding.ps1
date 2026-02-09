$path = "c:\projects\akilesiya\lib\users screen\profile_screen.dart"
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)

# Helper for safe replacement (escape regex special chars in match)
function Safe-Replace($text, $find, $replace) {
    # Escape regex special characters in the $find string
    $escapedFind = [regex]::Escape($find)
    return $text -replace $escapedFind, $replace
}

# Translations
$content = $content -replace "'christian_name': '.*?'", "'christian_name': 'የክርስትና ስም'"
$content = $content -replace "'mother_name': '.*?'", "'mother_name': 'የእናት ስም'"
$content = $content -replace "'gender': '.*?'", "'gender': 'ጾታ'"
$content = $content -replace "'age': '.*?'", "'age': 'ዕድሜ'"
$content = $content -replace "'dob': '.*?'", "'dob': 'የትውልድ ቀን'"
$content = $content -replace "'phone_number': '.*?'", "'phone_number': 'ስልክ ቁጥር'"
$content = $content -replace "'confession_father_name': '.*?'", "'confession_father_name': 'የንስሐ አባት ስም'"
$content = $content -replace "'spiritual_class': '.*?'", "'spiritual_class': 'የመንፈሳዊ ትምህርት ክፍል'"
$content = $content -replace "'kifil': '.*?'", "'kifil': 'ክፍል'"
$content = $content -replace "'academic_level': '.*?'", "'academic_level': 'የትምህርት ደረጃ'"
$content = $content -replace "'parent_name': '.*?'", "'parent_name': 'የወላጅ ስም'"
$content = $content -replace "'parent_phone_number': '.*?'", "'parent_phone_number': 'የወላጅ ስልክ ቁጥር'"
$content = $content -replace "'grade_points': '.*?'", "'grade_points': 'ውጤት'"

# Map Keys
$content = Safe-Replace $content "'á‹¨áŒ áˆ ': [" "'የግል': ["
$content = Safe-Replace $content "'áˆ˜áŠ•á ˆáˆ³á‹Š': ['confession" "'መንፈሳዊ': ['confession"
$content = Safe-Replace $content "'á‰µáˆ áˆ…áˆ­á‰µ áŠ¥áŠ“ á‰¤á‰°áˆ°á‰¥': [" "'ትምህርት እና ቤተሰብ': ["

# Conditionals
$content = Safe-Replace $content "if (tabTitle == 'á‹¨áŒ áˆ ')" "if (tabTitle == 'የግል')"
$content = Safe-Replace $content "if (tabTitle == 'áˆ˜áŠ•á ˆáˆ³á‹Š')" "if (tabTitle == 'መንፈሳዊ')"
$content = Safe-Replace $content "if (tabTitle == 'á‰µáˆ áˆ…áˆ­á‰µ áŠ¥áŠ“ á‰¤á‰°áˆ°á‰¥')" "if (tabTitle == 'ትምህርት እና ቤተሰብ')"

# TabText
$content = Safe-Replace $content 'text: "áˆ áŠ”á‰³")' 'text: "ሁኔታ")'
$content = Safe-Replace $content 'text: "á‹¨áŒ áˆ ")' 'text: "የግል")'
$content = Safe-Replace $content 'text: "áˆ˜áŠ•á ˆáˆ³á‹Š")' 'text: "መንፈሳዊ")'
$content = Safe-Replace $content 'text: "á‰µáˆ áˆ…áˆ­á‰µ áŠ¥áŠ“ á‰¤á‰°áˆ°á‰¥")' 'text: "ትምህርት እና ቤተሰብ")'

[System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
