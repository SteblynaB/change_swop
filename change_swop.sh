#!/bin/bash

# Отключаем текущий своп
echo "Отключаем текущий своп..."
sudo swapoff -a

# Проверяем, существует ли своп-файл
if [ -e /swapfile ]; then
    echo "Удаляем существующий своп-файл..."
    sudo rm /swapfile
fi

# Запрашиваем размер свопа у пользователя
while true; do
    read -p "Введите новый размер свопа (например, 16G): " SWAP_SIZE

    # Проверяем, что введенное значение является числом
    if [[ $SWAP_SIZE =~ ^[0-9]+$ ]]; then
        SWAP_SIZE="${SWAP_SIZE}G"  # Добавляем G, если введено только число
        break
    elif [[ $SWAP_SIZE =~ ^[0-9]+[Gg]$ ]]; then
        break  # Если уже указана G, просто выходим из цикла
    else
        echo "Неверный формат. Пожалуйста, введите размер, например: 16G или 512."
    fi
done

# Создаем новый файл свопа
echo "Создание файла свопа размером $SWAP_SIZE..."
if sudo fallocate -l $SWAP_SIZE /swapfile; then
    echo "Файл свопа успешно создан с использованием fallocate."
else
    echo "Ошибка при создании свопа с помощью fallocate. Попробуем использовать dd..."
    sudo dd if=/dev/zero of=/swapfile bs=1G count=${SWAP_SIZE%G}  # Убираем G и используем как количество
fi

# Установка правильных разрешений
echo "Установка прав доступа для своп-файла..."
sudo chmod 600 /swapfile

# Инициализация файла как своп
echo "Инициализация свопа..."
sudo mkswap /swapfile

# Включение свопа
echo "Включение свопа..."
sudo swapon /swapfile

# Проверка состояния свопа
echo "Проверка состояния свопа..."
free -h

echo "Скрипт выполнен успешно. Своп-файл изменен!"
