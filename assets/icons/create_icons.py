y#!/usr/bin/env python3
"""
Simple script to create app icons for PulseFit Pro
This creates a basic icon with a dumbbell symbol
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_icon(size, filename):
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Calculate dimensions based on size
    center = size // 2
    radius = int(size * 0.4)
    
    # Background circle with gradient effect
    for i in range(radius, 0, -1):
        alpha = int(255 * (1 - i / radius) * 0.8)
        color = (108, 92, 231, alpha)  # Purple gradient
        draw.ellipse([center - i, center - i, center + i, center + i], fill=color)
    
    # Draw dumbbell
    bar_width = int(size * 0.4)
    bar_height = int(size * 0.05)
    weight_radius = int(size * 0.08)
    
    # Left weight
    left_weight_x = center - bar_width // 2 - weight_radius
    draw.ellipse([left_weight_x - weight_radius, center - weight_radius, 
                  left_weight_x + weight_radius, center + weight_radius], 
                 fill=(255, 255, 255, 255))
    
    # Right weight
    right_weight_x = center + bar_width // 2 + weight_radius
    draw.ellipse([right_weight_x - weight_radius, center - weight_radius, 
                  right_weight_x + weight_radius, center + weight_radius], 
                 fill=(255, 255, 255, 255))
    
    # Bar
    bar_x = center - bar_width // 2
    bar_y = center - bar_height // 2
    draw.rectangle([bar_x, bar_y, bar_x + bar_width, bar_y + bar_height], 
                   fill=(255, 255, 255, 255))
    
    # Handles
    handle_width = int(size * 0.05)
    handle_height = int(size * 0.1)
    
    # Left handle
    left_handle_x = left_weight_x - weight_radius - handle_width
    left_handle_y = center - handle_height // 2
    draw.rectangle([left_handle_x, left_handle_y, 
                    left_handle_x + handle_width, left_handle_y + handle_height], 
                   fill=(255, 255, 255, 255))
    
    # Right handle
    right_handle_x = right_weight_x + weight_radius
    right_handle_y = center - handle_height // 2
    draw.rectangle([right_handle_x, right_handle_y, 
                    right_handle_x + handle_width, right_handle_y + handle_height], 
                   fill=(255, 255, 255, 255))
    
    # Save the image
    img.save(filename, 'PNG')
    print(f"Created {filename} ({size}x{size})")

def main():
    # Create icons directory if it doesn't exist
    os.makedirs('android/app/src/main/res/mipmap-hdpi', exist_ok=True)
    os.makedirs('android/app/src/main/res/mipmap-mdpi', exist_ok=True)
    os.makedirs('android/app/src/main/res/mipmap-xhdpi', exist_ok=True)
    os.makedirs('android/app/src/main/res/mipmap-xxhdpi', exist_ok=True)
    os.makedirs('android/app/src/main/res/mipmap-xxxhdpi', exist_ok=True)
    
    # Android icons
    create_icon(72, 'android/app/src/main/res/mipmap-hdpi/ic_launcher.png')
    create_icon(48, 'android/app/src/main/res/mipmap-mdpi/ic_launcher.png')
    create_icon(96, 'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png')
    create_icon(144, 'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png')
    create_icon(192, 'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png')
    
    # iOS icons (will be created manually)
    create_icon(1024, 'ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-1024.png')
    create_icon(180, 'ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-180.png')
    create_icon(120, 'ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-120.png')
    create_icon(87, 'ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-87.png')
    create_icon(80, 'ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-80.png')
    create_icon(76, 'ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-76.png')
    create_icon(60, 'ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-60.png')
    create_icon(58, 'ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-58.png')
    create_icon(40, 'ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-40.png')
    create_icon(29, 'ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-29.png')
    create_icon(20, 'ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-20.png')
    
    print("All icons created successfully!")

if __name__ == "__main__":
    main()
