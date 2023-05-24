local PERMISSIONS = {
  ['TELEPORT_TO_PLAYER'] = {
    ['OWNER'] = true,
    ['SUPPORT'] = true,
    ['MODERATOR'] = true,
    ['ADMINISTRATOR'] = true
  }
}

function hasRolePermission(permission, role)
  return PERMISSIONS[permission][role] or false
end