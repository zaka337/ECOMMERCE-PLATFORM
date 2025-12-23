# Firebase Security Rules

## Important: Configure Firebase Security Rules

To ensure proper privacy and security, you need to configure Firebase Realtime Database security rules.

### Access Firebase Console:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **satti-ecom**
3. Go to **Realtime Database** → **Rules** tab

### Recommended Security Rules:

```json
{
  "rules": {
    "products": {
      ".read": true,  // Everyone can read products
      "$productId": {
        ".write": "auth != null && (!data.exists() || data.child('storeOwnerId').val() == auth.uid || !data.child('storeOwnerId').exists())",
        ".validate": "newData.hasChildren(['name', 'price', 'imageUrl']) && newData.child('price').val() is number && newData.child('price').val() > 0"
      }
    },
    "stores": {
      ".read": "auth != null",  // Only authenticated users can read stores
      "$storeId": {
        ".write": "auth != null && (!data.exists() || data.child('ownerId').val() == auth.uid)",
        ".validate": "newData.hasChildren(['ownerId', 'storeName', 'ownerName', 'email']) && newData.child('ownerId').val() == auth.uid"
      }
    },
    "orders": {
      ".read": "auth != null && (data.child('userId').val() == auth.uid || root.child('stores').child(data.child('storeId').val()).child('ownerId').val() == auth.uid)",
      ".write": "auth != null && newData.child('userId').val() == auth.uid"
    }
  }
}
```

### Rule Explanations:

#### Products:
- **Read**: Everyone can read products (for browsing)
- **Write**: 
  - User must be authenticated
  - Can create new products (if `!data.exists()`)
  - Can only update/delete products they own (`data.child('storeOwnerId').val() == auth.uid`)
  - Can update products without `storeOwnerId` (legacy products)

#### Stores:
- **Read**: Only authenticated users can read store information
- **Write**: 
  - User must be authenticated
  - Can only create/update stores where `ownerId` matches their `auth.uid`
  - Validates that `ownerId` in data matches authenticated user

#### Orders:
- **Read**: Users can read their own orders, store owners can read orders for their store
- **Write**: Users can only create orders with their own `userId`

### Testing Rules:

After setting up rules, test them:
1. Try creating a product as a store owner
2. Try editing someone else's product (should fail)
3. Try creating a store
4. Try editing someone else's store (should fail)

### Important Notes:

1. **Privacy**: Store owners can only CRUD their own products
2. **Security**: All write operations require authentication
3. **Validation**: Rules validate data structure and ownership
4. **Legacy Support**: Old products without `storeOwnerId` can still be edited by authenticated users

### Alternative: Simpler Rules (Less Secure)

If you want simpler rules for development (NOT recommended for production):

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

**Warning**: This allows any authenticated user to modify any data. Use only for development/testing.

### Production Recommendations:

1. Enable Firebase App Check for additional security
2. Set up proper authentication requirements
3. Regularly review and update security rules
4. Monitor Firebase usage and access patterns
5. Consider using Cloud Functions for complex operations

