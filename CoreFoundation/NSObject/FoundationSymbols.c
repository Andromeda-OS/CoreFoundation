//
//  FoundationSymbols.c
//  CoreFoundation
//
//  Created by Stuart Crook on 24/03/2018.
//  Copyright © 2018 PureDarwin. All rights reserved.
//

#include <CoreFoundation/CFInternal.h>

// Exceptions
CONST_STRING_DECL(NSInternalInconsistencyException, "NSInternalInconsistencyException");
CONST_STRING_DECL(NSGenericException, "NSGenericException");
CONST_STRING_DECL(NSInvalidArgumentException, "NSInvalidArgumentException");
CONST_STRING_DECL(NSMallocException, "NSMallocException");
CONST_STRING_DECL(NSRangeException, "NSRangeException");

// Notifications
CONST_STRING_DECL(NSCalendarDayChangedNotification, "NSCalendarDayChangedNotification");
CONST_STRING_DECL(NSSystemClockDidChangeNotification, "NSSystemClockDidChangeNotification");

// These are all marked as CF_EXPORT and have "NS..." values when logged to the console
// So we need to declare the CF version AND add the NS version to the aliases file
 
// File System Resources
CONST_STRING_DECL(kCFURLNameKey, "NSURLNameKey")
CONST_STRING_DECL(kCFURLLocalizedNameKey, "NSURLLocalizedNameKey")
CONST_STRING_DECL(kCFURLIsRegularFileKey, "NSURLIsRegularFileKey")
CONST_STRING_DECL(kCFURLIsDirectoryKey, "NSURLIsDirectoryKey")
CONST_STRING_DECL(kCFURLIsSymbolicLinkKey, "NSURLIsSymbolicLinkKey")
CONST_STRING_DECL(kCFURLIsVolumeKey, "NSURLIsVolumeKey")
CONST_STRING_DECL(kCFURLIsPackageKey, "NSURLIsPackageKey")
CONST_STRING_DECL(kCFURLIsApplicationKey, "NSURLIsApplicationKey")
CONST_STRING_DECL(kCFURLApplicationIsScriptableKey, "NSURLApplicationIsScriptableKey")
CONST_STRING_DECL(kCFURLIsSystemImmutableKey, "NSURLIsSystemImmutableKey")
CONST_STRING_DECL(kCFURLIsUserImmutableKey, "NSURLIsUserImmutableKey")
CONST_STRING_DECL(kCFURLIsHiddenKey, "NSURLIsHiddenKey")
CONST_STRING_DECL(kCFURLHasHiddenExtensionKey, "NSURLHasHiddenExtensionKey")
CONST_STRING_DECL(kCFURLCreationDateKey, "NSURLCreationDateKey")
CONST_STRING_DECL(kCFURLContentAccessDateKey, "NSURLContentAccessDateKey")
CONST_STRING_DECL(kCFURLContentModificationDateKey, "NSURLContentModificationDateKey")
CONST_STRING_DECL(kCFURLAttributeModificationDateKey, "NSURLAttributeModificationDateKey")
CONST_STRING_DECL(kCFURLLinkCountKey, "NSURLLinkCountKey")
CONST_STRING_DECL(kCFURLParentDirectoryURLKey, "NSURLParentDirectoryURLKey")
CONST_STRING_DECL(kCFURLVolumeURLKey, "NSURLVolumeURLKey")
CONST_STRING_DECL(kCFURLTypeIdentifierKey, "NSURLTypeIdentifierKey")
CONST_STRING_DECL(kCFURLLocalizedTypeDescriptionKey, "NSURLLocalizedTypeDescriptionKey")
CONST_STRING_DECL(kCFURLLabelNumberKey, "NSURLLabelNumberKey")
CONST_STRING_DECL(kCFURLLabelColorKey, "NSURLLabelColorKey")
CONST_STRING_DECL(kCFURLLocalizedLabelKey, "NSURLLocalizedLabelKey")
CONST_STRING_DECL(kCFURLEffectiveIconKey, "NSURLEffectiveIconKey")
CONST_STRING_DECL(kCFURLCustomIconKey, "NSURLCustomIconKey")
CONST_STRING_DECL(kCFURLFileResourceIdentifierKey, "NSURLFileResourceIdentifierKey")
CONST_STRING_DECL(kCFURLVolumeIdentifierKey, "NSURLVolumeIdentifierKey")
CONST_STRING_DECL(kCFURLPreferredIOBlockSizeKey, "NSURLPreferredIOBlockSizeKey")
CONST_STRING_DECL(kCFURLIsReadableKey, "NSURLIsReadableKey")
CONST_STRING_DECL(kCFURLIsWritableKey, "NSURLIsWritableKey")
CONST_STRING_DECL(kCFURLIsExecutableKey, "NSURLIsExecutableKey")
CONST_STRING_DECL(kCFURLFileSecurityKey, "NSURLFileSecurityKey")
CONST_STRING_DECL(kCFURLIsExcludedFromBackupKey, "NSURLIsExcludedFromBackupKey")
CONST_STRING_DECL(kCFURLTagNamesKey, "NSURLTagNamesKey")
CONST_STRING_DECL(kCFURLPathKey, "NSURLPathKey")
CONST_STRING_DECL(kCFURLCanonicalPathKey, "NSURLCanonicalPathKey")
CONST_STRING_DECL(kCFURLIsMountTriggerKey, "NSURLIsMountTriggerKey")
CONST_STRING_DECL(kCFURLGenerationIdentifierKey, "NSURLGenerationIdentifierKey")
CONST_STRING_DECL(kCFURLDocumentIdentifierKey, "NSURLDocumentIdentifierKey")
CONST_STRING_DECL(kCFURLAddedToDirectoryDateKey, "NSURLAddedToDirectoryDateKey")
CONST_STRING_DECL(kCFURLQuarantinePropertiesKey, "NSURLQuarantinePropertiesKey")
CONST_STRING_DECL(kCFURLFileResourceTypeKey, "NSURLFileResourceTypeKey")

CONST_STRING_DECL(kCFURLKeysOfUnsetValuesKey, "NSURLKeysOfUnsetValuesKey")
 
// File System Object Types
CONST_STRING_DECL(kCFURLFileResourceTypeNamedPipe, "NSURLFileResourceTypeNamedPipe")
CONST_STRING_DECL(kCFURLFileResourceTypeCharacterSpecial, "NSURLFileResourceTypeCharacterSpecial")
CONST_STRING_DECL(kCFURLFileResourceTypeDirectory, "NSURLFileResourceTypeDirectory")
CONST_STRING_DECL(kCFURLFileResourceTypeBlockSpecial, "NSURLFileResourceTypeBlockSpecial")
CONST_STRING_DECL(kCFURLFileResourceTypeRegular, "NSURLFileResourceTypeRegular")
CONST_STRING_DECL(kCFURLFileResourceTypeSymbolicLink, "NSURLFileResourceTypeSymbolicLink")
CONST_STRING_DECL(kCFURLFileResourceTypeSocket, "NSURLFileResourceTypeSocket")
CONST_STRING_DECL(kCFURLFileResourceTypeUnknown, "NSURLFileResourceTypeUnknown")
 

// File Properties
CONST_STRING_DECL(kCFURLFileSizeKey, "NSURLFileSizeKey")
CONST_STRING_DECL(kCFURLFileAllocatedSizeKey, "NSURLFileAllocatedSizeKey")
CONST_STRING_DECL(kCFURLTotalFileSizeKey, "NSURLTotalFileSizeKey")
CONST_STRING_DECL(kCFURLTotalFileAllocatedSizeKey, "NSURLTotalFileAllocatedSizeKey")
CONST_STRING_DECL(kCFURLIsAliasFileKey, "NSURLIsAliasFileKey")
CONST_STRING_DECL(kCFURLFileProtectionKey, "NSURLFileProtectionKey")
 
// Protection Levels
CONST_STRING_DECL(kCFURLFileProtectionNone, "NSURLFileProtectionNone")
CONST_STRING_DECL(kCFURLFileProtectionComplete, "NSURLFileProtectionComplete")
CONST_STRING_DECL(kCFURLFileProtectionCompleteUnlessOpen, "NSURLFileProtectionCompleteUnlessOpen")
CONST_STRING_DECL(kCFURLFileProtectionCompleteUntilFirstUserAuthentication, "NSURLFileProtectionCompleteUntilFirstUserAuthentication")

// Volume Properties
CONST_STRING_DECL(kCFURLVolumeLocalizedFormatDescriptionKey, "NSURLVolumeLocalizedFormatDescriptionKey")
CONST_STRING_DECL(kCFURLVolumeTotalCapacityKey, "NSURLVolumeTotalCapacityKey")
CONST_STRING_DECL(kCFURLVolumeAvailableCapacityKey, "NSURLVolumeAvailableCapacityKey")
CONST_STRING_DECL(kCFURLVolumeResourceCountKey, "NSURLVolumeResourceCountKey")
CONST_STRING_DECL(kCFURLVolumeSupportsPersistentIDsKey, "NSURLVolumeSupportsPersistentIDsKey")
CONST_STRING_DECL(kCFURLVolumeSupportsSymbolicLinksKey, "NSURLVolumeSupportsSymbolicLinksKey")
CONST_STRING_DECL(kCFURLVolumeSupportsHardLinksKey, "NSURLVolumeSupportsHardLinksKey")
CONST_STRING_DECL(kCFURLVolumeSupportsJournalingKey, "NSURLVolumeSupportsJournalingKey")
CONST_STRING_DECL(kCFURLVolumeIsJournalingKey, "NSURLVolumeIsJournalingKey")
CONST_STRING_DECL(kCFURLVolumeSupportsSparseFilesKey, "NSURLVolumeSupportsSparseFilesKey")
CONST_STRING_DECL(kCFURLVolumeSupportsZeroRunsKey, "NSURLVolumeSupportsZeroRunsKey")
CONST_STRING_DECL(kCFURLVolumeSupportsCaseSensitiveNamesKey, "NSURLVolumeSupportsCaseSensitiveNamesKey")
CONST_STRING_DECL(kCFURLVolumeSupportsCasePreservedNamesKey, "NSURLVolumeSupportsCasePreservedNamesKey")
CONST_STRING_DECL(kCFURLVolumeSupportsRootDirectoryDatesKey, "NSURLVolumeSupportsRootDirectoryDatesKey")
CONST_STRING_DECL(kCFURLVolumeSupportsVolumeSizesKey, "NSURLVolumeSupportsVolumeSizesKey")
CONST_STRING_DECL(kCFURLVolumeSupportsRenamingKey, "NSURLVolumeSupportsRenamingKey")
CONST_STRING_DECL(kCFURLVolumeSupportsAdvisoryFileLockingKey, "NSURLVolumeSupportsAdvisoryFileLockingKey")
CONST_STRING_DECL(kCFURLVolumeSupportsExtendedSecurityKey, "NSURLVolumeSupportsExtendedSecurityKey")
CONST_STRING_DECL(kCFURLVolumeIsBrowsableKey, "NSURLVolumeIsBrowsableKey")
CONST_STRING_DECL(kCFURLVolumeMaximumFileSizeKey, "NSURLVolumeMaximumFileSizeKey")
CONST_STRING_DECL(kCFURLVolumeIsEjectableKey, "NSURLVolumeIsEjectableKey")
CONST_STRING_DECL(kCFURLVolumeIsRemovableKey, "NSURLVolumeIsRemovableKey")
CONST_STRING_DECL(kCFURLVolumeIsInternalKey, "NSURLVolumeIsInternalKey")
CONST_STRING_DECL(kCFURLVolumeIsAutomountedKey, "NSURLVolumeIsAutomountedKey")
CONST_STRING_DECL(kCFURLVolumeIsLocalKey, "NSURLVolumeIsLocalKey")
CONST_STRING_DECL(kCFURLVolumeIsReadOnlyKey, "NSURLVolumeIsReadOnlyKey")
CONST_STRING_DECL(kCFURLVolumeCreationDateKey, "NSURLVolumeCreationDateKey")
CONST_STRING_DECL(kCFURLVolumeURLForRemountingKey, "NSURLVolumeURLForRemountingKey")
CONST_STRING_DECL(kCFURLVolumeUUIDStringKey, "NSURLVolumeUUIDStringKey")
CONST_STRING_DECL(kCFURLVolumeNameKey, "NSURLVolumeNameKey")
CONST_STRING_DECL(kCFURLVolumeLocalizedNameKey, "NSURLVolumeLocalizedNameKey")
CONST_STRING_DECL(kCFURLVolumeIsEncryptedKey, "NSURLVolumeIsEncryptedKey")
CONST_STRING_DECL(kCFURLVolumeIsRootFileSystemKey, "NSURLVolumeIsRootFileSystemKey")
CONST_STRING_DECL(kCFURLVolumeSupportsCompressionKey, "NSURLVolumeSupportsCompressionKey")
CONST_STRING_DECL(kCFURLVolumeSupportsFileCloningKey, "NSURLVolumeSupportsFileCloningKey")
CONST_STRING_DECL(kCFURLVolumeSupportsSwapRenamingKey, "NSURLVolumeSupportsSwapRenamingKey")
CONST_STRING_DECL(kCFURLVolumeSupportsExclusiveRenamingKey, "NSURLVolumeSupportsExclusiveRenamingKey")
CONST_STRING_DECL(kCFURLVolumeAvailableCapacityForImportantUsageKey, "NSURLVolumeAvailableCapacityForImportantUsageKey")
CONST_STRING_DECL(kCFURLVolumeAvailableCapacityForOpportunisticUsageKey, "NSURLVolumeAvailableCapacityForOpportunisticUsageKey")
CONST_STRING_DECL(kCFURLVolumeSupportsAccessPermissionsKey, "NSURLVolumeSupportsAccessPermissionsKey")
CONST_STRING_DECL(kCFURLVolumeSupportsImmutableFilesKey, "NSURLVolumeSupportsImmutableFilesKey")

// Ubiquitous Item Properties
CONST_STRING_DECL(kCFURLIsUbiquitousItemKey, "NSURLIsUbiquitousItemKey")
CONST_STRING_DECL(kCFURLUbiquitousItemHasUnresolvedConflictsKey, "NSURLUbiquitousItemHasUnresolvedConflictsKey")
CONST_STRING_DECL(kCFURLUbiquitousItemIsDownloadedKey, "NSURLUbiquitousItemIsDownloadedKey")
CONST_STRING_DECL(kCFURLUbiquitousItemIsDownloadingKey, "NSURLUbiquitousItemIsDownloadingKey")
CONST_STRING_DECL(kCFURLUbiquitousItemIsUploadedKey, "NSURLUbiquitousItemIsUploadedKey")
CONST_STRING_DECL(kCFURLUbiquitousItemIsUploadingKey, "NSURLUbiquitousItemIsUploadingKey")
CONST_STRING_DECL(kCFURLUbiquitousItemPercentDownloadedKey, "NSURLUbiquitousItemPercentDownloadedKey")
CONST_STRING_DECL(kCFURLUbiquitousItemPercentUploadedKey, "NSURLUbiquitousItemPercentUploadedKey")
CONST_STRING_DECL(kCFURLUbiquitousItemDownloadingStatusKey, "NSURLUbiquitousItemDownloadingStatusKey")
CONST_STRING_DECL(kCFURLUbiquitousItemDownloadingErrorKey, "NSURLUbiquitousItemDownloadingErrorKey")
CONST_STRING_DECL(kCFURLUbiquitousItemUploadingErrorKey, "NSURLUbiquitousItemUploadingErrorKey")
CONST_STRING_DECL(kCFURLUbiquitousItemDownloadRequestedKey, "NSURLUbiquitousItemDownloadRequestedKey")
CONST_STRING_DECL(kCFURLUbiquitousItemContainerDisplayNameKey, "NSURLUbiquitousItemContainerDisplayNameKey")
CONST_STRING_DECL(kCFURLUbiquitousItemIsSharedKey, "NSURLUbiquitousItemIsSharedKey")
CONST_STRING_DECL(kCFURLUbiquitousSharedItemCurrentUserRoleKey, "NSURLUbiquitousSharedItemCurrentUserRoleKey")
CONST_STRING_DECL(kCFURLUbiquitousSharedItemRoleOwner, "NSURLUbiquitousSharedItemRoleOwner")
CONST_STRING_DECL(kCFURLUbiquitousSharedItemRoleParticipant, "NSURLUbiquitousSharedItemRoleParticipant")
CONST_STRING_DECL(kCFURLUbiquitousSharedItemOwnerNameComponentsKey, "NSURLUbiquitousSharedItemOwnerNameComponentsKey")
CONST_STRING_DECL(kCFURLUbiquitousSharedItemMostRecentEditorNameComponentsKey, "NSURLUbiquitousSharedItemMostRecentEditorNameComponentsKey")
 
// Ubiquitous Shared Item Premissions
CONST_STRING_DECL(kCFURLUbiquitousSharedItemCurrentUserPermissionsKey, "NSURLUbiquitousSharedItemCurrentUserPermissionsKey")
CONST_STRING_DECL(kCFURLUbiquitousSharedItemPermissionsReadOnly, "NSURLUbiquitousSharedItemPermissionsReadOnly")
CONST_STRING_DECL(kCFURLUbiquitousSharedItemPermissionsReadWrite, "NSURLUbiquitousSharedItemPermissionsReadWrite")
 
// Ubiquitous Item Downloading Status Key
CONST_STRING_DECL(kCFURLUbiquitousItemDownloadingStatusNotDownloaded, "NSURLUbiquitousItemDownloadingStatusNotDownloaded")
CONST_STRING_DECL(kCFURLUbiquitousItemDownloadingStatusDownloaded, "NSURLUbiquitousItemDownloadingStatusDownloaded")
CONST_STRING_DECL(kCFURLUbiquitousItemDownloadingStatusCurrent, "NSURLUbiquitousItemDownloadingStatusCurrent")
 
// deprecated
CONST_STRING_DECL(kCFURLUbiquitousSharedItemRoleKey, "NSURLUbiquitousSharedItemRoleKey")
CONST_STRING_DECL(kCFURLUbiquitousSharedItemOwnerNameKey, "NSURLUbiquitousSharedItemOwnerNameKey")
CONST_STRING_DECL(kCFURLUbiquitousSharedItemPermissionsKey, "NSURLUbiquitousSharedItemPermissionsKey")
CONST_STRING_DECL(kCFURLUbiquitousSharedItemReadOnlyPermissions, "NSURLUbiquitousSharedItemReadOnlyPermissions")
CONST_STRING_DECL(kCFURLUbiquitousSharedItemReadWritePermissions, "NSURLUbiquitousSharedItemReadWritePermissions")
 
// Foundation Only
CONST_STRING_DECL(kCFURLThumbnailDictionaryKey, "NSURLThumbnailDictionaryKey")
CONST_STRING_DECL(kCFURLThumbnailKey, "NSURLThumbnailKey")
CONST_STRING_DECL(kCFThumbnail1024x1024SizeKey, "NSThumbnail1024x1024SizeKey")
 
 
 
/*
 // And I also found these in CFURLPriv.h, so find where they are defined
 kCFURLBookmarkOriginalPathKey
 kCFURLBookmarkOriginalRelativePathKey
 kCFURLBookmarkOriginalRelativePathComponentsArrayKey
 kCFURLBookmarkOriginalVolumeNameKey
 kCFURLBookmarkOriginalVolumeCreationDateKey
 kCFURLBookmarkFileProviderStringKey
 

*/