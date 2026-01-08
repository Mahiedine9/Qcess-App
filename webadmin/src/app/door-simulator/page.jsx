"use client";

import React, { useState, useEffect, useRef } from "react";
import {
  FaWifi,
  FaCircle,
  FaLock,
  FaUnlock,
  FaExclamationTriangle,
} from "react-icons/fa";
import SockJS from "sockjs-client";
import { Client } from "@stomp/stompjs";



const DoorSimulatorPage = () => {
  const [doorState, setDoorState] = useState("LOCKED");
  const [logs, setLogs] = useState([]);
  const [deviceId] = useState("DOOR_01");
  const [isConnected, setIsConnected] = useState(false);
  const [reconnectAttempts, setReconnectAttempts] = useState(0);

  const stompClientRef = useRef(null);
  const reconnectTimeoutRef = useRef(null);

  const WS_HTTP_URL =
    typeof window !== "undefined"
      ? `${window.location.protocol}//${window.location.hostname}:8080/ws`
      : "http://localhost:8080/ws";

  const addLog = (type, message) => {
    const timestamp = new Date().toLocaleTimeString("fr-FR");
    setLogs((prev) =>
      [
        {
          id: Date.now() + Math.random(),
          time: timestamp,
          type,
          message,
        },
        ...prev,
      ].slice(0, 30)
    );
  };

  const sendEvent = (state) => {
    const client = stompClientRef.current;
    if (!client || !client.connected) return;

    const payload = {
      type: "EVENT",
      state,
      deviceId,
      timestamp: Date.now(),
    };


    client.publish({
      destination: "/app/door/events",
      body: JSON.stringify(payload),
    });

    addLog("EVENT", `📤 État envoyé: ${state}`);
  };

  const handleOpenCommand = (duration = 3000) => {
    if (doorState !== "LOCKED") {
      addLog("WARNING", "⚠️ Porte déjà ouverte ou en mouvement");
      return;
    }

    setDoorState("UNLOCKING");
    addLog("STATE", "🔓 Déverrouillage...");
    sendEvent("UNLOCKING");

    setTimeout(() => {
      setDoorState("OPEN");
      addLog("STATE", "✅ Porte ouverte");
      sendEvent("OPENED");

      setTimeout(() => {
        setDoorState("LOCKING");
        addLog("STATE", "🔒 Fermeture automatique...");
        sendEvent("LOCKING");

        setTimeout(() => {
          setDoorState("LOCKED");
          addLog("STATE", "🔐 Porte verrouillée");
          sendEvent("LOCKED");
        }, 1000);
      }, duration);
    }, 800);
  };

  const handleCloseCommand = () => {
    if (doorState === "OPEN") {
      setDoorState("LOCKING");
      addLog("STATE", "🔒 Fermeture manuelle...");

      setTimeout(() => {
        setDoorState("LOCKED");
        addLog("STATE", "🔐 Porte verrouillée");
        sendEvent("LOCKED");
      }, 1000);
    }
  };

  const handleLockCommand = () => {
    setDoorState("LOCKED");
    addLog("STATE", "🔐 Verrouillage forcé");
    sendEvent("LOCKED");
  };

  const handleWebSocketCommand = (data) => {
    if (!data) return;

    const command = data.command || data.type || "";

    if (!command) return;

    addLog("COMMAND", `📨 Commande reçue: ${command}`);

    if (command === "OPEN") {
      handleOpenCommand();
    } else if (command === "CLOSE") {
      handleCloseCommand();
    } else if (command === "LOCK" || command === "DENY") {
      if (command === "DENY") {
        addLog("STATE", "⛔ Accès refusé - porte reste verrouillée");
      }
      handleLockCommand();
    }
  };

  const setupStompClient = () => {
    const client = new Client({
      webSocketFactory: () => new SockJS(WS_HTTP_URL),
      reconnectDelay: 0,
      onConnect: () => {
        setIsConnected(true);
        setReconnectAttempts(0);
        addLog(
          "SYSTEM",
          `✅ Connecté au serveur WebSocket (topic /topic/door-control)`
        );

        client.subscribe("/topic/door-control", (message) => {
          let payload = null;
          const raw = message.body;

          // On log toujours le message brut pour le debug
          console.log("[DoorSimulator] Message STOMP brut:", raw);

          try {
            // Cas classique: le backend envoie du JSON {"command":"OPEN"}
            payload = JSON.parse(raw);
          } catch (e) {
            // Si ce n'est pas du JSON, on le traite comme une simple commande texte
            payload = { command: raw };
          }

          handleWebSocketCommand(payload);
        });
      },
      onStompError: (frame) => {
        console.error("STOMP error", frame);
        addLog("ERROR", "❌ Erreur STOMP depuis le broker");
      },
      onWebSocketError: (event) => {
        console.error("WebSocket error", event);
        addLog("ERROR", "❌ Erreur de connexion WebSocket");
      },
      onDisconnect: () => {
        setIsConnected(false);
        addLog("SYSTEM", "❌ Déconnecté du serveur");
      },
    });

    stompClientRef.current = client;
    client.activate();
  };

  useEffect(() => {
    setupStompClient();

    return () => {
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
      }
      const client = stompClientRef.current;
      if (client && client.active) {
        client.deactivate();
      }
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    if (!isConnected && reconnectAttempts < 5) {
      reconnectTimeoutRef.current = setTimeout(() => {
        setReconnectAttempts((prev) => prev + 1);
        addLog(
          "SYSTEM",
          `🔄 Tentative de reconnexion (${reconnectAttempts + 1}/5)...`
        );
        setupStompClient();
      }, 4000);
    }
  }, [isConnected, reconnectAttempts]);

  const getDoorRotation = () => {
    switch (doorState) {
      case "LOCKED":
        return 0;
      case "UNLOCKING":
        return 15;
      case "OPEN":
        return 85;
      case "LOCKING":
        return 15;
      default:
        return 0;
    }
  };

  const getStatusColor = () => {
    switch (doorState) {
      case "LOCKED":
        return "text-red-500";
      case "UNLOCKING":
        return "text-yellow-500";
      case "OPEN":
        return "text-green-500";
      case "LOCKING":
        return "text-yellow-500";
      default:
        return "text-gray-500";
    }
  };

  const getStatusText = () => {
    switch (doorState) {
      case "LOCKED":
        return "VERROUILLÉE";
      case "UNLOCKING":
        return "DÉVERROUILLAGE...";
      case "OPEN":
        return "OUVERTE";
      case "LOCKING":
        return "FERMETURE...";
      default:
        return "INCONNU";
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 text-white p-8">
      <div className="max-w-7xl mx-auto mb-8">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold mb-2">Contrôleur IP - WebSocket</h1>
            <p className="text-slate-400">
              Device ID: <span className="font-mono">{deviceId}</span>
            </p>
          </div>
          <div className="flex items-center gap-4">
            <div className="flex items-center gap-2">
              {isConnected ? (
                <>
                  <FaWifi className="w-5 h-5 text-green-500" />
                  <span className="text-sm text-green-500 font-semibold">
                    Connecté
                  </span>
                </>
              ) : (
                <>
                  <FaWifi className="w-5 h-5 text-red-500" />
                  <span className="text-sm text-red-500 font-semibold">
                    Déconnecté
                  </span>
                </>
              )}
            </div>
            {!isConnected && reconnectAttempts > 0 && (
              <span className="text-xs text-slate-400">
                Reconnexion {reconnectAttempts}/5
              </span>
            )}
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="bg-slate-800 rounded-2xl p-8 border border-slate-700">
          <div className="mb-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-xl font-semibold">Visualisation Temps Réel</h2>
              <div className={`flex items-center gap-2 ${getStatusColor()}`}>
                {doorState === "LOCKED" ? (
                  <FaLock className="w-5 h-5" />
                ) : (
                  <FaUnlock className="w-5 h-5" />
                )}
                <span className="font-mono font-bold">{getStatusText()}</span>
              </div>
            </div>
          </div>

          <div className="relative h-96 bg-gradient-to-b from-slate-700 to-slate-600 rounded-xl overflow-hidden flex items-center justify-center">
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="relative w-64 h-80">
                <div className="absolute inset-0 border-8 border-slate-900 rounded-lg"></div>

                <div
                  className="absolute top-2 left-2 right-2 bottom-2 bg-gradient-to-br from-slate-800 to-slate-900 rounded-lg shadow-2xl transition-all duration-700 origin-left"
                  style={{
                    transform: `perspective(800px) rotateY(${getDoorRotation()}deg)`,
                    boxShadow:
                      doorState === "OPEN"
                        ? "20px 20px 60px rgba(0,0,0,0.5)"
                        : "0 0 20px rgba(0,0,0,0.3)",
                  }}
                >
                  <div className="absolute inset-4 border-2 border-slate-700 rounded"></div>

                  <div
                    className="absolute right-6 top-1/2 -translate-y-1/2 w-3 h-12 bg-gradient-to-r from-yellow-600 to-yellow-500 rounded-full shadow-lg"
                    style={{ opacity: doorState === "OPEN" ? 0.3 : 1 }}
                  ></div>

                  <div className="absolute top-4 left-1/2 -translate-x-1/2">
                    <div
                      className={`w-3 h-3 rounded-full ${
                        doorState === "LOCKED" ? "bg-red-500" : "bg-green-500"
                      } shadow-lg animate-pulse`}
                    ></div>
                  </div>
                </div>

                {doorState === "OPEN" && (
                  <div className="absolute top-2 left-2 right-2 bottom-2 bg-gradient-to-r from-transparent via-yellow-200 to-transparent opacity-30 animate-pulse"></div>
                )}
              </div>
            </div>
          </div>

          <div className="mt-6 p-4 bg-slate-900 rounded-lg border border-slate-700">
            <div className="flex items-center gap-2 text-sm">
              <FaExclamationTriangle className="w-4 h-4 text-blue-400" />
              <span className="text-slate-300">
                {isConnected ? (
                  <>
                    En attente de commandes via
                    <span className="font-mono text-blue-400"> WebSocket</span>
                  </>
                ) : (
                  <span className="text-red-400">
                    Connexion au serveur impossible
                  </span>
                )}
              </span>
            </div>
          </div>
        </div>

        <div className="space-y-6">
          <div className="bg-slate-800 rounded-2xl p-6 border border-slate-700">
            <h2 className="text-xl font-semibold mb-4">État du Système</h2>
            <div className="space-y-3">
              <div className="flex justify-between items-center p-3 bg-slate-700 rounded-lg">
                <span className="text-slate-300">État Porte</span>
                <span className={`font-mono font-bold ${getStatusColor()}`}>
                  {doorState}
                </span>
              </div>
              <div className="flex justify-between items-center p-3 bg-slate-700 rounded-lg">
                <span className="text-slate-300">Connexion WebSocket</span>
                <div className="flex items-center gap-2">
                  <FaCircle
                    className={`w-3 h-3 fill-current ${
                      isConnected
                        ? "text-green-500 animate-pulse"
                        : "text-red-500"
                    }`}
                  />
                  <span className="font-mono text-sm">
                    {isConnected ? "ONLINE" : "OFFLINE"}
                  </span>
                </div>
              </div>
              <div className="flex justify-between items-center p-3 bg-slate-700 rounded-lg">
                <span className="text-slate-300">Device ID</span>
                <span className="font-mono text-sm">{deviceId}</span>
              </div>
              <div className="flex justify-between items-center p-3 bg-slate-700 rounded-lg">
                <span className="text-slate-300">Serveur</span>
                <span className="font-mono text-xs text-slate-400">
                  {WS_HTTP_URL}
                </span>
              </div>
            </div>
          </div>

          <div className="bg-slate-800 rounded-2xl p-6 border border-slate-700">
            <h2 className="text-xl font-semibold mb-4">Logs Temps Réel</h2>
            <div className="space-y-2 max-h-96 overflow-y-auto">
              {logs.map((log) => (
                <div
                  key={log.id}
                  className="p-3 bg-slate-900 rounded-lg border-l-4 border-slate-600"
                >
                  <div className="flex items-center justify-between mb-1">
                    <span
                      className={`text-xs font-mono px-2 py-1 rounded ${
                        log.type === "COMMAND"
                          ? "bg-blue-900 text-blue-300"
                          : log.type === "STATE"
                          ? "bg-purple-900 text-purple-300"
                          : log.type === "EVENT"
                          ? "bg-green-900 text-green-300"
                          : log.type === "SYSTEM"
                          ? "bg-cyan-900 text-cyan-300"
                          : log.type === "WARNING"
                          ? "bg-yellow-900 text-yellow-300"
                          : log.type === "ERROR"
                          ? "bg-red-900 text-red-300"
                          : "bg-slate-700 text-slate-300"
                      }`}
                    >
                      {log.type}
                    </span>
                    <span className="text-xs text-slate-500">{log.time}</span>
                  </div>
                  <p className="text-sm text-slate-300">{log.message}</p>
                </div>
              ))}
              {logs.length === 0 && (
                <p className="text-center text-slate-500 py-8">
                  En attente de commandes...
                </p>
              )}
            </div>
          </div>

          <div className="bg-blue-900 bg-opacity-30 rounded-2xl p-6 border border-blue-700">
            <h3 className="font-semibold mb-2 flex items-center gap-2">
              <FaWifi className="w-5 h-5" />
              Configuration WebSocket
            </h3>
            <div className="space-y-2 text-sm text-slate-300">
              <div>
                <span className="text-slate-400">URL SockJS:</span>
                <code className="ml-2 text-blue-400 font-mono text-xs">
                  {WS_HTTP_URL}
                </code>
              </div>
              <div>
                <span className="text-slate-400">Destination STOMP:</span>
                <code className="ml-2 text-blue-400 font-mono text-xs">
                  /topic/door-control
                </code>
              </div>
              <div>
                <span className="text-slate-400">Format:</span>
                <code className="ml-2 text-blue-400 font-mono text-xs">
                  JSON {"{ \"command\": \"OPEN\" | \"DENY\" }"}
                </code>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DoorSimulatorPage;
