$html = @"
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
html,body{margin:0;padding:0;background:black;height:100%;overflow:hidden}
video{width:100vw;height:100vh;object-fit:contain}
</style>
</head>
<body>
<video autoplay loop muted playsinline>
<source src="https://chess-ai.42web.io/images/tuff4.mp4" type="video/mp4">
</video>
</body>
</html>
"@

$encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($html))
$url = "data:text/html;base64,$encoded"

Start-Process "msedge.exe" "--kiosk $url --edge-kiosk-type=fullscreen --autoplay-policy=no-user-gesture-required"
