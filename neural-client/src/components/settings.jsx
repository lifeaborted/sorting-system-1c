import HttpSender from "../http/http-sender.js";
import {useState} from "react";

const Settings = ({
    onClose = () => {}
}) => {
    const [newURL, setNewURL] = useState(HttpSender.getBaseURL())

    const setServerUrl = (url) => {
        HttpSender.setBaseURL(url)
        onClose()
    }

    return (
        <div className="settings-modal">
            <div className="settings-content">
                <h3>Укажите адрес нейросети</h3>
                <div>
                    <div className="settings-input_row">
                        <span>{HttpSender.getProtocol()}://</span>
                        <input
                            type="text"
                            value={newURL}
                            onChange={(e) => setNewURL(e.target.value)}
                            placeholder="Введите URL сервера"
                            className="settings-input"
                        />
                        <span>{HttpSender.getPath()}</span>
                    </div>

                    <div className="settings-actions">
                        <button type="button" className="button-primary" onClick={() => setServerUrl(newURL)}>
                            Сохранить
                        </button>
                        <button type="button" className="button-secondary" onClick={onClose}>
                            Отмена
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Settings;