"use client";
import React, {useEffect, useState} from 'react';
import { HiOutlineOfficeBuilding, HiOutlineLocationMarker, HiX } from "react-icons/hi";
import { MdOutlinePeopleAlt } from "react-icons/md";

const OrganisationPage = () => {

  const [form, setForm] = useState({
    name: "",
    address: "",
    description: "",
    phoneNumber: "",
  });

  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(null);
  const [error, setError] = useState(null);
  const [isModalOpen, setIsModalOpen] = React.useState(false);
  const [modalVisible, setModalVisible] = React.useState(false);

  const [roles, setRoles] = useState([]);
  
  // Formulaire de rôle
  const [roleForm, setRoleForm] = useState({ name: "", description: "" });
  const [roleLoading, setRoleLoading] = useState(false);
  const [roleError, setRoleError] = useState(null);
  const [editingRole, setEditingRole] = useState(null);
  
  // Modal de suppression
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [deleteModalVisible, setDeleteModalVisible] = useState(false);
  const [roleToDelete, setRoleToDelete] = useState(null);

  // États pour les zones
  const [zones, setZones] = useState([]);
  const [zonesLoading, setZonesLoading] = useState(false);
  const [isZoneModalOpen, setIsZoneModalOpen] = useState(false);
  const [zoneModalVisible, setZoneModalVisible] = useState(false);
  const [selectedZone, setSelectedZone] = useState(null);

  // Modal création zone
  const [isCreateZoneModalOpen, setIsCreateZoneModalOpen] = useState(false);
  const [createZoneModalVisible, setCreateZoneModalVisible] = useState(false);
  const [zoneForm, setZoneForm] = useState({ name: "", description: "" });
  const [zoneFormError, setZoneFormError] = useState(null);
  const [zoneFormLoading, setZoneFormLoading] = useState(false);

  // Gestion des rôles de la zone
  const [isEditingRoles, setIsEditingRoles] = useState(false);
  const [selectedRoleIds, setSelectedRoleIds] = useState([]);
  const [roleUpdateLoading, setRoleUpdateLoading] = useState(false);
  const [roleUpdateSuccess, setRoleUpdateSuccess] = useState(null);
  const [roleUpdateError, setRoleUpdateError] = useState(null);

  // Modal de confirmation de suppression de zone
  const [isDeleteZoneModalOpen, setIsDeleteZoneModalOpen] = useState(false);
  const [deleteZoneModalVisible, setDeleteZoneModalVisible] = useState(false);
  const [zoneToDelete, setZoneToDelete] = useState(null);
  const [deleteZoneLoading, setDeleteZoneLoading] = useState(false);

  const openModal = () => {
    setIsModalOpen(true);
    setTimeout(() => {
      setModalVisible(true);
    }, 10);
  }
  const closeModal = () => {
    setModalVisible(false);
    setTimeout(() => {
      setIsModalOpen(false);
      setRoleForm({ name: "", description: "" });
      setEditingRole(null);
      setRoleError(null);
    }, 300);
  }

  const openDeleteModal = (role) => {
    setRoleToDelete(role);
    setIsDeleteModalOpen(true);
    setTimeout(() => setDeleteModalVisible(true), 10);
  }

  const closeDeleteModal = () => {
    setDeleteModalVisible(false);
    setTimeout(() => {
      setIsDeleteModalOpen(false);
      setRoleToDelete(null);
    }, 300);
  }

  const openEditModal = (role) => {
    setEditingRole(role);
    setRoleForm({ name: role.name, description: role.description || "" });
    setIsModalOpen(true);
    setTimeout(() => setModalVisible(true), 10);
  }

  const openZoneModal = (zone) => {
    console.log("Zone sélectionnée:", zone);
    setSelectedZone(zone);
    const roleIds = zone.allowedRoleIds || zone.allowedRolesIds || zone.allowedRoles || [];
    console.log("Role IDs détectés:", roleIds);
    setSelectedRoleIds(roleIds);
    setIsEditingRoles(false);
    setRoleUpdateSuccess(null);
    setRoleUpdateError(null);
    setIsZoneModalOpen(true);
    setTimeout(() => setZoneModalVisible(true), 10);
  }

  const closeZoneModal = () => {
    setZoneModalVisible(false);
    setTimeout(() => {
      setIsZoneModalOpen(false);
      setSelectedZone(null);
      setIsEditingRoles(false);
      setSelectedRoleIds([]);
      setRoleUpdateSuccess(null);
      setRoleUpdateError(null);
    }, 300);
  }

  const openCreateZoneModal = () => {
    setZoneForm({ name: "", description: "" });
    setZoneFormError(null);
    setIsCreateZoneModalOpen(true);
    setTimeout(() => setCreateZoneModalVisible(true), 10);
  }

  const closeCreateZoneModal = () => {
    setCreateZoneModalVisible(false);
    setTimeout(() => {
      setIsCreateZoneModalOpen(false);
      setZoneForm({ name: "", description: "" });
      setZoneFormError(null);
    }, 300);
  }

  const openDeleteZoneModal = (zone) => {
    setZoneToDelete(zone);
    setIsDeleteZoneModalOpen(true);
    setTimeout(() => setDeleteZoneModalVisible(true), 10);
  }

  const closeDeleteZoneModal = () => {
    setDeleteZoneModalVisible(false);
    setTimeout(() => {
      setIsDeleteZoneModalOpen(false);
      setZoneToDelete(null);
    }, 300);
  }

  // Fonction pour télécharger le QR code
  const downloadQrCode = async (zoneId, zoneName) => {
    try {
      const response = await fetch(
        `${process.env.NEXT_PUBLIC_API_BASE_URL}/access/zones/${zoneId}/qr`,
        {
          credentials: "include",
        }
      );

      if (!response.ok) {
        throw new Error("Impossible de télécharger le QR code");
      }

      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `qrcode-${zoneName.replace(/\s+/g, '-').toLowerCase()}.png`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);
    } catch (err) {
      console.error("Erreur lors du téléchargement du QR code:", err);
      setRoleUpdateError("Erreur lors du téléchargement du QR code");
      setTimeout(() => setRoleUpdateError(null), 3000);
    }
  };

  const toggleZoneRoleSelection = (roleId) => {
    setSelectedRoleIds(prev =>
      prev.includes(roleId)
        ? prev.filter(id => id !== roleId)
        : [...prev, roleId]
    );
  }

  const startEditingRoles = () => {
    setIsEditingRoles(true);
    setRoleUpdateSuccess(null);
    setRoleUpdateError(null);
  }

  const cancelEditingRoles = () => {
    setIsEditingRoles(false);
    const roleIds = selectedZone?.allowedRoleIds || selectedZone?.allowedRolesIds || selectedZone?.allowedRoles || [];
    setSelectedRoleIds(roleIds);
    setRoleUpdateError(null);
  }

  async function handleUpdateZoneRoles() {
    if (!selectedZone) return;

    setRoleUpdateLoading(true);
    setRoleUpdateError(null);
    setRoleUpdateSuccess(null);

    try {
      const res = await fetch(
        `${process.env.NEXT_PUBLIC_API_BASE_URL}/zones/${selectedZone.id}/allowed-roles`,
        {
          method: "PUT",
          headers: { "Content-Type": "application/json" },
          credentials: "include",
          body: JSON.stringify({ roleIds: selectedRoleIds }),
        }
      );

      if (!res.ok) {
        const errorText = await res.text();
        throw new Error(errorText || "Erreur lors de la mise à jour des rôles");
      }

      const message = selectedRoleIds.length === 0 
        ? "Zone définie comme publique (accessible à tous)" 
        : "Rôles mis à jour avec succès !";
      
      setRoleUpdateSuccess(message);
      await loadZones();
      
      setSelectedZone(prev => ({
        ...prev,
        allowedRoleIds: selectedRoleIds,
        allowedRolesIds: selectedRoleIds
      }));
      
      setIsEditingRoles(false);
      
      setTimeout(() => setRoleUpdateSuccess(null), 3000);
    } catch (err) {
      setRoleUpdateError(err.message);
    } finally {
      setRoleUpdateLoading(false);
    }
  }

  async function handleDeleteZone() {
    if (!zoneToDelete) return;

    setDeleteZoneLoading(true);

    try {
      const res = await fetch(
        `${process.env.NEXT_PUBLIC_API_BASE_URL}/zones/delete/${zoneToDelete.id}`,
        {
          method: "DELETE",
          credentials: "include",
        }
      );

      if (!res.ok) {
        const errorText = await res.text();
        throw new Error(errorText || "Erreur lors de la suppression de la zone");
      }

      await loadZones();
      closeDeleteZoneModal();
      
      if (selectedZone?.id === zoneToDelete.id) {
        closeZoneModal();
      }
    } catch (err) {
      setRoleUpdateError(err.message);
    } finally {
      setDeleteZoneLoading(false);
    }
  }

  async function handleCreateZone(e) {
    e.preventDefault();
    setZoneFormError(null);

    if (!zoneForm.name.trim()) {
      setZoneFormError("Le nom de la zone est obligatoire.");
      return;
    }

    setZoneFormLoading(true);

    try {
      const res = await fetch(
        `${process.env.NEXT_PUBLIC_API_BASE_URL}/zones`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          credentials: "include",
          body: JSON.stringify(zoneForm),
        }
      );

      if (!res.ok) throw new Error("Erreur lors de la création de la zone");

      await loadZones();
      closeCreateZoneModal();
    } catch (err) {
      setZoneFormError(err.message);
    } finally {
      setZoneFormLoading(false);
    }
  }

  async function handleRoleSubmit(e) {
    e.preventDefault();
    setRoleError(null);

    if (!roleForm.name.trim()) {
      setRoleError("Le nom du rôle est obligatoire.");
      return;
    }

    setRoleLoading(true);

    try {
      const url = editingRole
        ? `${process.env.NEXT_PUBLIC_API_BASE_URL}/organizations/update-custom-role/${editingRole.id}`
        : `${process.env.NEXT_PUBLIC_API_BASE_URL}/organizations/create-custom-role`;

      const method = editingRole ? "PATCH" : "POST";

      const res = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify(roleForm),
      });

      if (!res.ok) throw new Error("Erreur lors de l'enregistrement du rôle");

      await loadRoles();
      closeModal();
    } catch (err) {
      setRoleError(err.message);
    } finally {
      setRoleLoading(false);
    }
  }

  async function handleDeleteRole() {
    if (!roleToDelete) return;

    setRoleLoading(true);

    try {
      const res = await fetch(
        `${process.env.NEXT_PUBLIC_API_BASE_URL}/organizations/delete-custom-role/${roleToDelete.id}`,
        {
          method: "DELETE",
          credentials: "include",
        }
      );

      if (!res.ok) throw new Error("Erreur lors de la suppression");

      await loadRoles();
      closeDeleteModal();
    } catch (err) {
      setRoleError(err.message);
    } finally {
      setRoleLoading(false);
    }
  }

  const loadRoles = React.useCallback(async () => {
    try {
      const res = await fetch(
        `${process.env.NEXT_PUBLIC_API_BASE_URL}/organizations/roles`,
        { credentials: "include" }
      );
      
      if (!res.ok) {
        setError("Impossible de charger les rôles");
        return;
      }
      
      const data = await res.json();
      setRoles(data);
    } catch (e) {
      console.error("Erreur chargement rôles:", e);
      setError("Une erreur est survenue lors du chargement des rôles");
    }
  }, []);

  const loadZones = React.useCallback(async () => {
    setZonesLoading(true);
    try {
      const res = await fetch(
        `${process.env.NEXT_PUBLIC_API_BASE_URL}/zones`,
        { credentials: "include" }
      );
      
      if (!res.ok) {
        console.error("Erreur HTTP zones:", res.status);
        setError("Impossible de charger les zones");
        return;
      }
      
      const data = await res.json();
      setZones(data);
    } catch (e) {
      console.error("Erreur zones:", e);
      setError("Une erreur est survenue lors du chargement des zones");
    } finally {
      setZonesLoading(false);
    }
  }, []);

  React.useEffect(() => {
    loadRoles();
    loadZones();
  }, [loadRoles, loadZones]);

  React.useEffect(() => {
    if (selectedZone && zones.length > 0) {
      const updatedZone = zones.find(z => z.id === selectedZone.id);
      if (updatedZone) {
        setSelectedZone(prev => ({
          ...prev,
          ...updatedZone
        }));
      }
    }
  }, [zones]);

  function handleChange(e) {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError(null);
    setSuccess(null);
    const isEmpty =
        !form.name.trim() &&
        !form.address.trim() &&
        !form.description.trim() &&
        !form.phoneNumber.trim();

    if (isEmpty) {
      setError("Veuillez remplir au moins un champ avant de sauvegarder.");
      return;
    }

    setLoading(true);

    try {
      const res = await fetch(
          `${process.env.NEXT_PUBLIC_API_BASE_URL}/organizations/update-details`,
          {
            method: "PATCH",
            headers: {
              "Content-Type": "application/json",
            },
            credentials: "include",
            body: JSON.stringify(form),
          }
      );

      if (!res.ok) {
        let errorMessage = "Impossible de mettre à jour l'organisation";
        
        try {
          const errorData = await res.json();
          if (errorData.message) {
            errorMessage = errorData.message;
          }
        } catch (parseError) {
          console.error("Erreur parsing réponse:", parseError);
        }
        
        setError(errorMessage);
        setLoading(false);
        return;
      }

      setSuccess("Organisation mise à jour avec succès !");
    } catch (err) {
      console.error("Erreur mise à jour organisation:", err);
      setError("Une erreur est survenue lors de la mise à jour");
    } finally {
      setLoading(false);
    }
  }

  const handleRegenerateQr = async (zoneId) => {
    try {
      const res = await fetch(
        `${process.env.NEXT_PUBLIC_API_BASE_URL}/access/zones/${zoneId}/regqr`,
        { method: 'GET', credentials: 'include' }
      );
      if (!res.ok) {
        throw new Error("Erreur lors de la régénération du QR code");
      }
      await loadZones();
      setSuccess("QR code régénéré avec succès !");
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      setError(err.message || "Erreur lors de la régénération du QR code");
      setTimeout(() => setError(null), 3000);
    }
  }

  return (
    <>
      {/* Modal Créer/Modifier rôle */}
      {isModalOpen && (
        <div className={`fixed inset-0 z-50 flex items-center justify-center bg-black/40 transition-opacity duration-300 ${modalVisible ? "opacity-100" : "opacity-0"}`}>
          <div className={`w-full max-w-md rounded-2xl bg-white p-6 shadow-xl transform transition-all duration-200 ${modalVisible ? "scale-100 translate-y-0 opacity-100" : "scale-95 translate-y-2 opacity-0"}`}>
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold text-gray-900">
                {editingRole ? "Modifier le rôle" : "Créer un rôle"}
              </h2>
              <button onClick={closeModal} className="text-gray-400 hover:text-gray-600 text-xl leading-none">×</button>
            </div>

            <form onSubmit={handleRoleSubmit} className="space-y-4">
              <div className="space-y-1">
                <label className="text-sm font-medium text-gray-700">
                  Nom du rôle <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  value={roleForm.name}
                  onChange={(e) => setRoleForm({ ...roleForm, name: e.target.value })}
                  className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm outline-none placeholder:text-gray-400 focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500"
                  placeholder="Ex: Manager, Technicien..."
                  required
                />
              </div>

              <div className="space-y-1">
                <label className="text-sm font-medium text-gray-700">Description</label>
                <textarea
                  value={roleForm.description}
                  onChange={(e) => setRoleForm({ ...roleForm, description: e.target.value })}
                  className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm outline-none placeholder:text-gray-400 focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 resize-none"
                  rows={3}
                  placeholder="Description du rôle..."
                />
              </div>

              {roleError && (
                <div className="flex items-center gap-3 rounded-lg border border-red-200 bg-red-50 px-4 py-3">
                  <div className="flex h-8 w-8 items-center justify-center rounded-full bg-red-100">
                    <span className="text-red-600 font-bold text-sm">!</span>
                  </div>
                  <p className="text-sm text-red-800 font-medium">{roleError}</p>
                </div>
              )}

              <div className="flex justify-end gap-3 pt-4">
                <button
                  type="button"
                  onClick={closeModal}
                  className="rounded-lg border border-slate-200 px-5 py-2.5 text-sm font-semibold text-gray-700 hover:bg-slate-50 active:scale-95 transition-all duration-200 cursor-pointer"
                  disabled={roleLoading}
                >
                  Annuler
                </button>
                <button
                  type="submit"
                  className="rounded-lg bg-indigo-600 px-5 py-2.5 text-sm font-semibold text-white hover:bg-indigo-700 active:scale-95 disabled:bg-slate-300 disabled:cursor-not-allowed transition-all duration-200 shadow-sm cursor-pointer"
                  disabled={roleLoading}
                >
                  {roleLoading ? "Enregistrement..." : editingRole ? "Modifier" : "Créer"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal Confirmation suppression rôle */}
      {isDeleteModalOpen && roleToDelete && (
        <div className={`fixed inset-0 z-50 flex items-center justify-center bg-black/40 transition-opacity duration-300 ${deleteModalVisible ? "opacity-100" : "opacity-0"}`}>
          <div className={`w-full max-w-md rounded-2xl bg-white p-6 shadow-xl transform transition-all duration-200 ${deleteModalVisible ? "scale-100 translate-y-0 opacity-100" : "scale-95 translate-y-2 opacity-0"}`}>
            <div className="flex items-center gap-3 mb-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-full bg-red-100">
                <span className="text-red-600 text-2xl">⚠️</span>
              </div>
              <div>
                <h2 className="text-lg font-semibold text-gray-900">Confirmer la suppression</h2>
                <p className="text-sm text-gray-500 mt-1">Cette action est irréversible</p>
              </div>
            </div>

            <p className="text-sm text-gray-700 mb-6">
              Êtes-vous sûr de vouloir supprimer le rôle <span className="font-semibold text-gray-900">"{roleToDelete.name}"</span> ?
            </p>

            <div className="flex justify-end gap-3">
              <button
                onClick={closeDeleteModal}
                className="rounded-lg border border-slate-200 px-5 py-2.5 text-sm font-semibold text-gray-700 hover:bg-slate-50 active:scale-95 transition-all duration-200 cursor-pointer"
                disabled={roleLoading}
              >
                Annuler
              </button>
              <button
                onClick={handleDeleteRole}
                className="rounded-lg bg-red-600 px-5 py-2.5 text-sm font-semibold text-white hover:bg-red-700 active:scale-95 disabled:bg-slate-300 disabled:cursor-not-allowed transition-all duration-200 shadow-sm cursor-pointer"
                disabled={roleLoading}
              >
                {roleLoading ? "Suppression..." : "Supprimer"}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal Confirmation suppression zone */}
      {isDeleteZoneModalOpen && zoneToDelete && (
        <div className={`fixed inset-0 z-50 flex items-center justify-center bg-black/40 transition-opacity duration-300 ${deleteZoneModalVisible ? "opacity-100" : "opacity-0"}`}>
          <div className={`w-full max-w-md rounded-2xl bg-white p-6 shadow-xl transform transition-all duration-200 ${deleteZoneModalVisible ? "scale-100 translate-y-0 opacity-100" : "scale-95 translate-y-2 opacity-0"}`}>
            <div className="flex items-center gap-3 mb-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-full bg-red-100">
                <span className="text-red-600 text-2xl">⚠️</span>
              </div>
              <div>
                <h2 className="text-lg font-semibold text-gray-900">Supprimer la zone</h2>
                <p className="text-sm text-gray-500 mt-1">Cette action est irréversible</p>
              </div>
            </div>

            <p className="text-sm text-gray-700 mb-6">
              Êtes-vous sûr de vouloir supprimer la zone <span className="font-semibold text-gray-900">"{zoneToDelete.name}"</span> ?
              <br />
              <span className="text-red-600 font-medium">Tous les accès associés seront perdus.</span>
            </p>

            <div className="flex justify-end gap-3">
              <button
                onClick={closeDeleteZoneModal}
                className="rounded-lg border border-slate-200 px-5 py-2.5 text-sm font-semibold text-gray-700 hover:bg-slate-50 active:scale-95 transition-all duration-200 cursor-pointer"
                disabled={deleteZoneLoading}
              >
                Annuler
              </button>
              <button
                onClick={handleDeleteZone}
                className="rounded-lg bg-red-600 px-5 py-2.5 text-sm font-semibold text-white hover:bg-red-700 active:scale-95 disabled:bg-slate-300 disabled:cursor-not-allowed transition-all duration-200 shadow-sm cursor-pointer"
                disabled={deleteZoneLoading}
              >
                {deleteZoneLoading ? "Suppression..." : "Supprimer"}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal Création Zone */}
      {isCreateZoneModalOpen && (
        <div className={`fixed inset-0 z-50 flex items-center justify-center bg-black/40 transition-opacity duration-300 ${createZoneModalVisible ? "opacity-100" : "opacity-0"}`}>
          <div className={`w-full max-w-lg rounded-2xl bg-white p-6 shadow-xl transform transition-all duration-200 ${createZoneModalVisible ? "scale-100 translate-y-0 opacity-100" : "scale-95 translate-y-2 opacity-0"}`}>
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold text-gray-900">Créer une zone</h2>
              <button onClick={closeCreateZoneModal} className="text-gray-400 hover:text-gray-600 text-xl leading-none">×</button>
            </div>

            <form onSubmit={handleCreateZone} className="space-y-4">
              <div className="space-y-1">
                <label className="text-sm font-medium text-gray-700">
                  Nom de la zone <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  value={zoneForm.name}
                  onChange={(e) => setZoneForm({ ...zoneForm, name: e.target.value })}
                  className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm outline-none placeholder:text-gray-400 focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500"
                  placeholder="Ex: Zone A, Entrepôt Nord..."
                  required
                />
              </div>

              <div className="space-y-1">
                <label className="text-sm font-medium text-gray-700">Description</label>
                <textarea
                  value={zoneForm.description}
                  onChange={(e) => setZoneForm({ ...zoneForm, description: e.target.value })}
                  className="w-full rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm outline-none placeholder:text-gray-400 focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 resize-none"
                  rows={3}
                  placeholder="Description de la zone..."
                />
              </div>

              {/* ✅ Info sur zone publique par défaut */}
              <div className="flex items-start gap-3 rounded-lg border border-blue-200 bg-blue-50 px-4 py-3">
                <div className="flex h-8 w-8 items-center justify-center rounded-full bg-blue-100 flex-shrink-0">
                  <span className="text-blue-600 font-bold text-sm">ℹ</span>
                </div>
                <p className="text-sm text-blue-800">
                  <strong>Zone publique :</strong> Par défaut, la zone sera accessible à tous les membres. 
                  Vous pourrez définir les rôles autorisés après la création.
                </p>
              </div>

              {zoneFormError && (
                <div className="flex items-center gap-3 rounded-lg border border-red-200 bg-red-50 px-4 py-3">
                  <div className="flex h-8 w-8 items-center justify-center rounded-full bg-red-100">
                    <span className="text-red-600 font-bold text-sm">!</span>
                  </div>
                  <p className="text-sm text-red-800 font-medium">{zoneFormError}</p>
                </div>
              )}

              <div className="flex justify-end gap-3 pt-4">
                <button
                  type="button"
                  onClick={closeCreateZoneModal}
                  className="rounded-lg border border-slate-200 px-5 py-2.5 text-sm font-semibold text-gray-700 hover:bg-slate-50 active:scale-95 transition-all duration-200 cursor-pointer"
                  disabled={zoneFormLoading}
                >
                  Annuler
                </button>
                <button
                  type="submit"
                  className="rounded-lg bg-indigo-600 px-5 py-2.5 text-sm font-semibold text-white hover:bg-indigo-700 active:scale-95 disabled:bg-slate-300 disabled:cursor-not-allowed transition-all duration-200 shadow-sm cursor-pointer"
                  disabled={zoneFormLoading}
                >
                  {zoneFormLoading ? "Création..." : "Créer la zone"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal Détails Zone avec gestion des rôles */}
      {isZoneModalOpen && selectedZone && (
        <div className={`fixed inset-0 z-50 flex items-center justify-center bg-black/40 transition-opacity duration-300 ${zoneModalVisible ? "opacity-100" : "opacity-0"}`}>
          <div className={`w-full max-w-2xl rounded-2xl bg-white shadow-xl transform transition-all duration-200 max-h-[90vh] overflow-y-auto ${zoneModalVisible ? "scale-100 translate-y-0 opacity-100" : "scale-95 translate-y-2 opacity-0"}`}>
            {/* Header */}
            <div className="flex items-center justify-between border-b border-slate-200 px-6 py-4 sticky top-0 bg-white z-10">
              <div className="flex items-center gap-3">
                <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-indigo-100 text-indigo-700 font-bold text-lg">
                  {selectedZone.name.charAt(0).toUpperCase()}
                </div>
                <div>
                  <h2 className="text-lg font-semibold text-gray-900">{selectedZone.name}</h2>
                  <p className="text-sm text-gray-500">{selectedZone.description || "Aucune description"}</p>
                </div>
              </div>
              <button onClick={closeZoneModal} className="text-gray-400 hover:text-gray-600 transition-colors">
                <HiX className="h-6 w-6" />
              </button>
            </div>

            {/* Contenu */}
            <div className="p-6 space-y-4">
              {/* Informations */}
              <div className="space-y-3">
                <div className="flex items-center justify-between py-2 border-b border-slate-100">
                  <span className="text-sm font-medium text-gray-600">Statut</span>
                  <span className={`inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-semibold ${
                    selectedZone.status === "ACTIVE"
                      ? "bg-emerald-50 text-emerald-700"
                      : "bg-slate-100 text-slate-600"
                  }`}>
                    <span className={`h-1.5 w-1.5 rounded-full ${
                      selectedZone.status === "ACTIVE" ? "bg-emerald-500" : "bg-slate-400"
                    }`}></span>
                    {selectedZone.status === "ACTIVE" ? "Active" : "Inactive"}
                  </span>
                </div>

                <div className="flex items-center justify-between py-2 border-b border-slate-100">
                  <span className="text-sm font-medium text-gray-600">Créée le</span>
                  <span className="text-sm text-gray-700">
                    {new Date(selectedZone.createdAt).toLocaleDateString("fr-FR", {
                      day: "2-digit",
                      month: "long",
                      year: "numeric",
                    })}
                  </span>
                </div>

                <div className="flex items-center justify-between py-2 border-b border-slate-100">
                  <span className="text-sm font-medium text-gray-600">Type d'accès</span>
                  {/* ✅ Afficher "Publique" ou nombre de rôles */}
                  {selectedRoleIds.length === 0 ? (
                    <span className="inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-semibold bg-amber-50 text-amber-700">
                      <span className="h-1.5 w-1.5 rounded-full bg-amber-500"></span>
                      Publique (tous les membres)
                    </span>
                  ) : (
                    <span className="text-sm text-gray-700">
                      {selectedRoleIds.length} rôle(s) autorisé(s)
                    </span>
                  )}
                </div>
              </div>

              {/* Messages de succès/erreur */}
              {roleUpdateSuccess && (
                <div className="flex items-center gap-3 rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3">
                  <div className="flex h-8 w-8 items-center justify-center rounded-full bg-emerald-100">
                    <span className="text-emerald-600 font-bold text-sm">✓</span>
                  </div>
                  <p className="text-sm text-emerald-800 font-medium">{roleUpdateSuccess}</p>
                </div>
              )}

              {roleUpdateError && (
                <div className="flex items-center gap-3 rounded-lg border border-red-200 bg-red-50 px-4 py-3">
                  <div className="flex h-8 w-8 items-center justify-center rounded-full bg-red-100">
                    <span className="text-red-600 font-bold text-sm">!</span>
                  </div>
                  <p className="text-sm text-red-800 font-medium">{roleUpdateError}</p>
                </div>
              )}

              {/* Gestion des rôles */}
              <div className="pt-4 border-t border-slate-200">
                <div className="flex items-center justify-between mb-3">
                  <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider">
                    {isEditingRoles ? "Modifier les rôles autorisés" : "Rôles avec accès"}
                  </p>
                  {!isEditingRoles && (
                    <button
                      onClick={startEditingRoles}
                      className="text-xs font-semibold text-indigo-600 hover:text-indigo-700 transition-colors cursor-pointer"
                    >
                      ✏️ Modifier
                    </button>
                  )}
                </div>

                {isEditingRoles ? (
                  <>
                    {/* ✅ Info pour désélectionner tous les rôles */}
                    <div className="mb-3 flex items-start gap-3 rounded-lg border border-amber-200 bg-amber-50 px-4 py-3">
                      <div className="flex h-8 w-8 items-center justify-center rounded-full bg-amber-100 flex-shrink-0">
                        <span className="text-amber-600 font-bold text-sm">💡</span>
                      </div>
                      <p className="text-sm text-amber-800">
                        <strong>Astuce :</strong> Désélectionnez tous les rôles pour rendre la zone publique (accessible à tous).
                      </p>
                    </div>

                    {roles.length > 0 ? (
                      <div className="space-y-2 max-h-64 overflow-y-auto border border-slate-200 rounded-lg p-3">
                        {roles.map((role) => (
                          <label
                            key={role.id}
                            className="flex items-center gap-3 p-2 rounded-lg hover:bg-slate-50 cursor-pointer transition-colors"
                          >
                            <input
                              type="checkbox"
                              checked={selectedRoleIds.includes(role.id)}
                              onChange={() => toggleZoneRoleSelection(role.id)}
                              className="h-4 w-4 rounded border-slate-300 text-indigo-600 focus:ring-indigo-500 cursor-pointer"
                            />
                            <div className="flex items-center gap-2 flex-1">
                              <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-indigo-100 text-indigo-700 font-medium text-xs">
                                {role.name.charAt(0).toUpperCase()}
                              </div>
                              <span className="text-sm font-medium text-gray-900">{role.name}</span>
                            </div>
                          </label>
                        ))}
                      </div>
                    ) : (
                      <div className="text-sm text-gray-500 text-center py-4 border border-slate-200 rounded-lg bg-slate-50">
                        Aucun rôle disponible.
                      </div>
                    )}

                    <div className="flex justify-end gap-2 mt-4">
                      <button
                        onClick={cancelEditingRoles}
                        className="rounded-lg border border-slate-200 px-4 py-2 text-sm font-semibold text-gray-700 hover:bg-slate-50 active:scale-95 transition-all duration-200 cursor-pointer"
                        disabled={roleUpdateLoading}
                      >
                        Annuler
                      </button>
                      <button
                        onClick={handleUpdateZoneRoles}
                        className="rounded-lg bg-indigo-600 px-4 py-2 text-sm font-semibold text-white hover:bg-indigo-700 active:scale-95 disabled:bg-slate-300 disabled:cursor-not-allowed transition-all duration-200 shadow-sm cursor-pointer"
                        disabled={roleUpdateLoading}
                      >
                        {roleUpdateLoading ? "Enregistrement..." : "Enregistrer"}
                      </button>
                    </div>
                  </>
                ) : (
                  <>
                    {selectedRoleIds.length > 0 ? (
                      <div className="flex flex-wrap gap-2">
                        {selectedRoleIds.map((roleId) => {
                          const role = roles.find(r => r.id === roleId);
                          return (
                            <span
                              key={roleId}
                              className="inline-flex items-center gap-2 rounded-lg bg-indigo-50 px-3 py-2 text-xs font-medium text-indigo-700 border border-indigo-100"
                            >
                              <div className="h-6 w-6 flex items-center justify-center rounded bg-indigo-100 text-indigo-700 font-semibold text-xs">
                                {role?.name.charAt(0).toUpperCase() || '?'}
                              </div>
                              {role?.name || `Rôle #${roleId}`}
                            </span>
                          );
                        })}
                      </div>
                    ) : (
                      /*  Message pour zone publique */
                      <div className="flex items-center gap-3 rounded-lg border border-amber-200 bg-amber-50 px-4 py-4">
                        <div className="flex h-10 w-10 items-center justify-center rounded-full bg-amber-100">
                          <span className="text-amber-600 text-xl">🌍</span>
                        </div>
                        <div>
                          <p className="text-sm font-medium text-amber-900">Zone publique</p>
                          <p className="text-xs text-amber-700 mt-1">
                            Accessible à tous les membres de l'organisation
                          </p>
                        </div>
                      </div>
                    )}
                  </>
                )}
              </div>
            </div>

            {/* Footer */}
            <div className="flex justify-between gap-3 border-t border-slate-200 px-6 py-4 sticky bottom-0 bg-white">
              <button
                onClick={() => openDeleteZoneModal(selectedZone)}
                className="rounded-lg bg-red-600 px-5 py-2.5 text-sm font-semibold text-white hover:bg-red-700 active:scale-95 transition-all duration-200 shadow-sm cursor-pointer"
              >
                Supprimer la zone
              </button>
              <div className="flex gap-3">
                <button
                  onClick={() => downloadQrCode(selectedZone.id, selectedZone.name)}
                  className="inline-flex items-center gap-2 rounded-lg bg-teal-600 px-5 py-2.5 text-sm font-semibold text-white hover:bg-teal-700 active:scale-95 transition-all duration-200 shadow-sm cursor-pointer"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                  </svg>
                  Télécharger QR Code
                </button>
                <button
                  onClick={closeZoneModal}
                  className="rounded-lg border border-slate-200 px-5 py-2.5 text-sm font-semibold text-gray-700 hover:bg-slate-50 active:scale-95 transition-all duration-200 cursor-pointer"
                >
                  Fermer
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      <div className="flex flex-col min-h-screen gap-6 bg-slate-50">

        <div className="flex flex-col gap-2">
          <h1 className="text-2xl text-gray-900">
            Configuration de l'organisation
          </h1>
          <p className="mt-1 text-sm text-gray-400">
            Gérez les paramètres et les informations de votre organisation ici.
          </p>
        </div>

        {/* Section Organisation */}
        <div>
          <div className="rounded-2xl bg-white p-6 shadow-sm border border-slate-200">
            <div className="flex flex-col gap-3 mb-6">
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-indigo-50">
                  <HiOutlineOfficeBuilding className="h-5 w-5 text-indigo-600" />
                </div>
                <div>
                  <h2 className="text-lg font-semibold text-gray-900">Informations de l'organisation</h2>
                  <p className="text-sm text-gray-500">Configurez les informations générales de votre organisation</p>
                </div>
              </div>
            </div>

            <div className="flex flex-col">
              <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-5">
                {/* Nom */}
                <div className="flex flex-col gap-2">
                  <label className="text-sm font-semibold text-gray-700">Nom de l'organisation</label>
                  <input
                    type="text"
                    name="name"
                    value={form.name}
                    onChange={handleChange}
                    className="rounded-lg border border-slate-200 bg-white px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all"
                    placeholder="Entrez le nom"
                  />
                </div>

                {/* Adresse */}
                <div className="flex flex-col gap-2">
                  <label className="text-sm font-semibold text-gray-700">Adresse</label>
                  <input
                    type="text"
                    name="address"
                    value={form.address}
                    onChange={handleChange}
                    className="rounded-lg border border-slate-200 bg-white px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all"
                    placeholder="123 Rue Example, Paris"
                  />
                </div>

                {/* Téléphone */}
                <div className="flex flex-col gap-2">
                  <label className="text-sm font-semibold text-gray-700">Téléphone</label>
                  <input
                    type="text"
                    name="phoneNumber"
                    value={form.phoneNumber}
                    onChange={handleChange}
                    className="rounded-lg border border-slate-200 bg-white px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all"
                    placeholder="+33 6 12 34 56 78"
                  />
                </div>

                {/* Description */}
                <div className="flex flex-col gap-2 md:col-span-2">
                  <label className="text-sm font-semibold text-gray-700">Description</label>
                  <textarea
                    name="description"
                    value={form.description}
                    onChange={handleChange}
                    className="rounded-lg border border-slate-200 bg-white px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all resize-none"
                    rows={4}
                    placeholder="Décrivez votre organisation..."
                  />
                </div>

                {/* Messages */}
                {error && (
                  <div className="md:col-span-2 flex items-center gap-3 rounded-lg border border-red-200 bg-red-50 px-4 py-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-full bg-red-100">
                      <span className="text-red-600 font-bold text-sm">!</span>
                    </div>
                    <p className="text-sm text-red-800 font-medium">{error}</p>
                  </div>
                )}

                {success && (
                  <div className="md:col-span-2 flex items-center gap-3 rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-full bg-emerald-100">
                      <span className="text-emerald-600 font-bold text-sm">✓</span>
                    </div>
                    <p className="text-sm text-emerald-800 font-medium">{success}</p>
                  </div>
                )}

                {/* Bouton */}
                <div className="md:col-span-2 flex justify-end">
                  <button
                    type="submit"
                    disabled={loading}
                    className="rounded-lg bg-indigo-600 px-6 py-2.5 text-sm font-semibold text-white hover:bg-indigo-700 active:scale-95 disabled:bg-slate-300 disabled:cursor-not-allowed transition-all duration-200 shadow-sm cursor-pointer"
                  >
                    {loading ? "Enregistrement en cours..." : "Sauvegarder les modifications"}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>

        {/* Section Rôles */}
        <div className="rounded-2xl bg-white p-6 shadow-sm border border-slate-200">
          <div className="flex justify-between items-start gap-4 mb-6">
            <div className="flex flex-col gap-2">
              <div className="flex items-center gap-2">
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-indigo-50">
                  <MdOutlinePeopleAlt className="h-5 w-5 text-indigo-600" />
                </div>
                <div>
                  <h2 className="text-lg font-semibold text-gray-900">Rôles personnalisés</h2>
                  <p className="text-sm text-gray-500">{roles.length} {roles.length > 1 ? 'rôles configurés' : 'rôle configuré'}</p>
                </div>
              </div>
            </div>
            <button 
              onClick={openModal} 
              className="rounded-lg bg-indigo-600 px-4 py-2.5 text-sm font-medium text-white hover:bg-indigo-700 active:scale-95 transition-all duration-200 shadow-sm cursor-pointer"
            >
              + Ajouter un rôle
            </button>
          </div>

          <div className="overflow-hidden rounded-xl border border-slate-200">
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200">
                  <th className="px-4 py-3 text-left font-semibold text-gray-700">Nom du rôle</th>
                  <th className="px-4 py-3 text-left font-semibold text-gray-700">Description</th>
                  <th className="px-4 py-3 text-right font-semibold text-gray-700">Actions</th>
                </tr>
              </thead>

              <tbody className="divide-y divide-slate-100">
              {roles.length > 0 ? (
                roles.map((role) => (
                  <tr 
                    key={role.id} 
                    className="hover:bg-indigo-50/30 transition-all duration-200 cursor-pointer group"
                  >
                    <td className="px-4 py-4">
                      <div className="flex items-center gap-3">
                        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-indigo-100 text-indigo-700 font-medium text-xs group-hover:bg-indigo-200 transition-colors">
                          {role.name.charAt(0).toUpperCase()}
                        </div>
                        <span className="font-medium text-gray-900 group-hover:text-indigo-700 transition-colors">{role.name}</span>
                      </div>
                    </td>
                    <td className="px-4 py-4 text-gray-600">
                      {role.description || (
                        <span className="italic text-gray-400">
                          Aucune description
                        </span>
                      )}
                    </td>
                    <td className="px-4 py-4">
                      <div className="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity duration-200">
                        <button 
                          onClick={() => openEditModal(role)}
                          className="px-3 py-1.5 text-xs font-medium text-indigo-600 hover:bg-indigo-100 rounded-md transition-colors cursor-pointer"
                        >
                          Modifier
                        </button>
                        <button 
                          onClick={() => openDeleteModal(role)}
                          className="px-3 py-1.5 text-xs font-medium text-red-600 hover:bg-red-100 rounded-md transition-colors cursor-pointer"
                        >
                          Supprimer
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={3} className="px-4 py-12 text-center">
                    <div className="flex flex-col items-center gap-3">
                      <div className="flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
                        <MdOutlinePeopleAlt className="h-8 w-8 text-slate-400" />
                      </div>
                      <div>
                        <p className="text-sm font-medium text-gray-900">Aucun rôle configuré</p>
                        <p className="text-sm text-gray-500 mt-1">Commencez par créer votre premier rôle personnalisé</p>
                      </div>
                    </div>
                  </td>
                </tr>
              )}
              </tbody>
            </table>
          </div>
        </div>

        {/* Section Zones */}
        <div className="rounded-2xl bg-white p-6 shadow-sm border border-slate-200">
          <div className="flex justify-between items-start gap-4 mb-6">
            <div className="flex flex-col gap-2">
              <div className="flex items-center gap-2">
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-indigo-50">
                  <HiOutlineLocationMarker className="h-5 w-5 text-indigo-600" />
                </div>
                <div>
                  <h2 className="text-lg font-semibold text-gray-900">Zones de l'organisation</h2>
                  <p className="text-sm text-gray-500">{zones.length} {zones.length > 1 ? 'zones configurées' : 'zone configurée'}</p>
                </div>
              </div>
            </div>
            <button 
              onClick={openCreateZoneModal}
              className="rounded-lg bg-indigo-600 px-4 py-2.5 text-sm font-medium text-white hover:bg-indigo-700 active:scale-95 transition-all duration-200 shadow-sm cursor-pointer"
            >
              + Créer une zone
            </button>
          </div>

          {zonesLoading ? (
            <div className="flex flex-col items-center justify-center py-12">
              <div className="h-10 w-10 animate-spin rounded-full border-4 border-slate-200 border-t-indigo-600"></div>
              <p className="mt-3 text-sm text-gray-500">Chargement des zones...</p>
            </div>
          ) : (
            <div className="overflow-hidden rounded-xl border border-slate-200">
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-slate-50 border-b border-slate-200">
                    <th className="px-4 py-3 text-left font-semibold text-gray-700">Nom de la zone</th>
                    <th className="px-4 py-3 text-left font-semibold text-gray-700">Description</th>
                    <th className="px-4 py-3 text-center font-semibold text-gray-700">Type d'accès</th>
                    <th className="px-4 py-3 text-center font-semibold text-gray-700">Statut</th>
                    <th className="px-4 py-3 text-right font-semibold text-gray-700">Actions</th>
                  </tr>
                </thead>

                <tbody className="divide-y divide-slate-100">
                {zones.length > 0 ? (
                  zones.map((zone) => {
                    const roleCount = zone.allowedRoles?.length || zone.allowedRoleIds?.length || 0;
                    const isPublic = roleCount === 0;
                    
                    return (
                      <tr 
                        key={zone.id} 
                        className="hover:bg-gradient-to-r hover:from-indigo-50/50 hover:to-teal-50/50 transition-all duration-300 cursor-pointer group border-l-2 border-transparent hover:border-l-indigo-500"
                      >
                        <td className="px-4 py-4">
                          <div className="flex items-center gap-3">
                            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-indigo-100 text-indigo-700 font-semibold text-sm group-hover:bg-indigo-600 group-hover:text-white group-hover:scale-110 transition-all duration-300 shadow-sm group-hover:shadow-md">
                              {zone.name.charAt(0).toUpperCase()}
                            </div>
                            <span className="font-semibold text-gray-900 group-hover:text-indigo-700 transition-colors duration-300">{zone.name}</span>
                          </div>
                        </td>
                        <td className="px-4 py-4 text-gray-600 group-hover:text-gray-900 transition-colors">
                          {zone.description || (
                            <span className="italic text-gray-400 group-hover:text-gray-500">
                              Aucune description
                            </span>
                          )}
                        </td>
                        <td className="px-4 py-4 text-center">
                          {/* ✅ Badge "Publique" ou nombre de rôles */}
                          {isPublic ? (
                            <span className="inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-semibold bg-amber-50 text-amber-700 group-hover:bg-amber-100 group-hover:scale-105 transition-all duration-300">
                              <span className="h-1.5 w-1.5 rounded-full bg-amber-500"></span>
                              Publique
                            </span>
                          ) : (
                            <span className="inline-flex items-center rounded-full bg-indigo-50 px-3 py-1 text-xs font-medium text-indigo-700 group-hover:bg-indigo-100 group-hover:scale-105 transition-all duration-300">
                              {roleCount} rôle(s)
                            </span>
                          )}
                        </td>
                        <td className="px-4 py-4 text-center">
                          <span className={`inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-semibold group-hover:scale-105 transition-all duration-300 ${
                            zone.status === "ACTIVE"
                              ? "bg-emerald-50 text-emerald-700 group-hover:bg-emerald-100"
                              : "bg-slate-100 text-slate-600 group-hover:bg-slate-200"
                          }`}>
                            <span className={`h-1.5 w-1.5 rounded-full ${
                              zone.status === "ACTIVE" ? "bg-emerald-500" : "bg-slate-400"
                            }`}></span>
                            {zone.status === "ACTIVE" ? "Active" : "Inactive"}
                          </span>
                        </td>
                        <td className="px-4 py-4">
                          <div className="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-all duration-300 transform group-hover:translate-x-0 translate-x-2">
                            <button 
                              onClick={() => openZoneModal(zone)}
                              className="px-3 py-2 text-xs font-semibold text-indigo-600 bg-indigo-50 hover:bg-indigo-600 hover:text-white rounded-lg transition-all duration-200 cursor-pointer shadow-sm hover:shadow"
                            >
                              👁️ Gérer
                            </button>
                            <button
                              onClick={() => handleRegenerateQr(zone.id)}
                              className="px-3 py-2 text-xs font-semibold text-amber-600 bg-amber-50 hover:bg-amber-600 hover:text-white rounded-lg transition-all duration-200 cursor-pointer shadow-sm hover:shadow"
                              title="Régénérer le QR Code"
                            >
                              🔄 Régénérer QR
                            </button>
                          </div>
                        </td>
                      </tr>
                    );
                  })
                ) : (
                  <tr>
                    <td colSpan={5} className="px-4 py-12 text-center">
                      <div className="flex flex-col items-center gap-3">
                        <div className="flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
                          <HiOutlineLocationMarker className="h-8 w-8 text-slate-400" />
                        </div>
                        <div>
                          <p className="text-sm font-medium text-gray-900">Aucune zone configurée</p>
                          <p className="text-sm text-gray-500 mt-1">Créez votre première zone pour commencer</p>
                        </div>
                      </div>
                    </td>
                  </tr>
                )}
                </tbody>
              </table>
            </div>
          )}
        </div>

      </div>
    </>
  );
}

export default OrganisationPage;