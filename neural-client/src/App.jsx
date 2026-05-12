import React, { useState } from 'react';
import { IconUpload, IconSettings } from '@tabler/icons-react';
import './App.css';
import HttpSender from "./http/http-sender.js"
import Notification from "./components/notification.jsx"
import Settings from "./components/settings.jsx";

const App = () => {
    const [image, setImage] = useState(null)
    const [imagePreview, setImagePreview] = useState(null)
    const [showSettings, setShowSettings] = useState(false)
    const [notification, setNotification] = useState({})
    const [isLoading, setIsLoading] = useState(false)

    const handleImageChange = (e) =>
    {
        const file = e.target.files[0]
        if (file)
        {
            setImage(file)
            const reader = new FileReader()
            reader.onloadend = () => {setImagePreview(reader.result)}
            reader.readAsDataURL(file)
        }
    }

    const handleSubmit = async () =>
    {
        if (!image)
        {
            setNotification({message: 'Выберите изображение', type: 'error'})
            return
        }

        setIsLoading(true)
        HttpSender.SendImage(image).then(() => {
            setNotification({message: 'Изображение отправлено!', type: 'success'})
            setImage(null)
            setImagePreview(null)
        }).catch(e => {
            setNotification({message: `Ошибка отправки: ${e.message}`, type: 'error'})
        }).finally(() => setIsLoading(false))
    }

    return (
        <div className="app-container">
            <button className="settings-button" onClick={() => setShowSettings(!showSettings)} title="Настройки">
                <IconSettings size={24}/>
            </button>

            <Notification notification={notification}/>

            {showSettings && (
                <Settings onClose={() => {setShowSettings(false)}}/>
            )}

            <div className="upload-form">
                <div className="upload-area">
                    <label className="image-picker" style={imagePreview ? { backgroundImage: `url(${imagePreview})` } : {}}>
                        {imagePreview ? (
                            <div className="picker-overlay">
                                <span>Изменить фото</span>
                            </div>
                        ) : (
                            <div className="picker-placeholder">
                                <IconUpload size={48} />
                                <span>Выберите изображение</span>
                            </div>
                        )}
                        <input
                            type="file"
                            accept="image/*"
                            onChange={handleImageChange}
                            style={{ display: 'none' }}
                        />
                    </label>

                    <button className="submit-button" onClick={handleSubmit} disabled={!image || isLoading}>
                        {isLoading ? 'Отправка...' : 'Отправить'}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default App;