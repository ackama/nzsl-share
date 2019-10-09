const ajax = $.ajax;

const add = (signId, folderId) => {
  return ajax({
    method: "POST",
    url: "/folder_memberships",
    // Params must be submitted in correct format
    // eslint-disable-next-line camelcase
    data: { folder_collection: { sign_id: signId, folder_id: folderId } },
    dataType: "script"
  });
};

const remove = (membershipId) => {
  return ajax({
    method: "DELETE",
    url: `/folder_memberships/${membershipId}`,
    dataType: "script"
  });
};


const updateMembership = (evt) => {
  const target = evt.target;
  const { folderId, signId, membershipId } = target.dataset;

  return (target.checked ? add(signId, folderId) : remove(membershipId));
};

const init = () => {
  $("[data-trigger='update-folder-membership']").change(updateMembership);
};


$(init);
