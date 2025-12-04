# Proposal: Today's Win and BMI Features

## Today's Win (Успех дня)
This stat should track the user's daily achievements and display a motivational message.

### Calculation:
- **Scoring System (0-100 points)**:
  - Completed workout today: +40 points
  - Met nutrition goals (within 10% of targets): +30 points
  - Logged all meals: +20 points
  - Maintained streak (consecutive days): +10 points

### Display:
- Show a score out of 100
- Display an achievement icon (🏆, ⭐, 🎯, 💪) based on score:
  - 0-25: 😐 "Начни сегодня!"
  - 26-50: 😊 "Хорошее начало!"
  - 51-75: 😄 "Отличная работа!"
  - 76-100: 🔥 "Ты на высоте!"

### Tooltip Help Text:
"Успех дня показывает ваши достижения сегодня:
• Тренировка: 40 баллов
• Питание: 30 баллов
• Записи блюд: 20 баллов
• Серия дней: 10 баллов"

---

## BMI (ИМТ - Индекс Массы Тела)
Body Mass Index calculation and health status indication.

### Calculation:
```
BMI = weight (kg) / (height (m))²
```

### Categories:
- < 18.5: Недостаточный вес
- 18.5-24.9: Нормальный вес
- 25-29.9: Избыточный вес
- 30+: Ожирение

### Display:
- Show calculated BMI value (e.g., "22.4")
- Show category with colored indicator
- Add trend arrow if tracking weight changes (↑ ↓ →)

### Tooltip Help Text:
"ИМТ рассчитывается по формуле: вес (кг) / рост² (м)
• < 18.5: Недостаточный вес
• 18.5-24.9: Норма ✅
• 25-29.9: Избыточный вес
• 30+: Ожирение

Обновляется автоматически при изменении веса."

---

## Implementation Notes:
1. Both stats should update in real-time as user completes activities
2. Store daily Today's Win scores for historical tracking
3. BMI updates automatically when user updates weight in profile
4. Add tooltip info button (ⓘ) next to each stat label
5. Make stats tappable to show detailed breakdown
