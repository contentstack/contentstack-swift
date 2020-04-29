# ![Contentstack](https://www.contentstack.com/docs/static/images/contentstack.png)

# Contentstack Swift SDK

Contentstack is a headless CMS with an API-first approach. It is a CMS that developers can use to build powerful cross-platform applications in their favorite languages. Build your application frontend, and Contentstack will take care of the rest. [Read More](https://www.contentstack.com/).

Contentstack provides iOS SDK to build application on top of iOS. Given below is the detailed guide and helpful resources to get started with our iOS SDK.


### Prerequisite

Latest Xcode and Mac OS X


### Setup and Installation

To use this SDK on iOS platform, you will have to install the SDK according to the steps given below.

##### CocoaPods

1. Add the following line to your Podfile:
2. pod 'ContentstackSwift'
3. Run pod install, and you should now have the latest Contentstack release.

##### Import Header/Module   

 ```sh
 import ContentstackSwift
 ```
### Key Concepts for using Contentstack

#### Stack

A stack is like a container that holds the content of your app. Learn more about [Stacks](https://www.contentstack.com/docs/guide/stack).

#### Content Type

Content type lets you define the structure or blueprint of a page or a section of your digital property. It is a form-like page that gives Content Managers an interface to input and upload content. [Read more](https://www.contentstack.com/docs/guide/content-types).

#### Entry

An entry is the actual piece of content created using one of the defined content types. Learn more about [Entries](https://www.contentstack.com/docs/guide/content-management#working-with-entries).


#### Asset


Assets refer to all the media files (images, videos, PDFs, audio files, and so on) uploaded to Contentstack. These files can be used in multiple entries. Read more about [Assets](https://www.contentstack.com/docs/guide/content-management#working-with-assets).


#### Environment

A publishing environment corresponds to one or more deployment servers or a content delivery destination where the entries need to be published. Learn how to work with [Environments](https://www.contentstack.com/docs/guide/environments).

### Contentstack iOS SDK: 5-minute Quickstart

#### Initializing your SDK

To start using the SDK in your application, you will need to initialize the stack by providing the required keys and values associated with them:
            ```
     let stack:Stack = Contentstack.stack(apiKey: API_KEY, deliveryToken: DELIVERY_TOKEN, environment: ENVIRONMENT)
     ```

To get the api credentials mentioned above, you need to log into your Contentstack account and then in your top panel navigation, go to Settings -&gt; Stack to view both your API Key and your Delivery Token

The stack object that is returned is a Contentstack client object, which can be used to initialize different modules and make queries against our [Content Delivery API](https://contentstack.com/docs/apis/content-delivery-api/). The initialization process for each module is explained in the following section.


#### Querying content from your stack

To fetch all entries of of a content type, use the query given below:

 ```
 let stack = Contentstack.stack(apiKey: apiKey,
             deliveryToken: deliveryToken,
             environment: environment)

 stack.contentType(uid: contentTypeUID).entry().query()
    .find { (result: Result<ContentstackResponse<EntryModel>, Error>, response: ResponseType) in
      switch result {
      case .success(let contentstackResponse):
          // Contentstack response with AssetModel array in items.
      case .failure(let error):
          //Error Message
      }
  }
 ```

To fetch a specific entry from a content type, use the following query:

 ```
  let stack = Contentstack.stack(apiKey: apiKey,
              deliveryToken: deliveryToken,
              environment: environment)
 
  stack.contentType(uid: contentTypeUID).entry(uid: UID)
  .fetch { (result: Result<EntryModel, Error>, response: ResponseType) in
     switch result {
     case .success(let model):
          //Model retrive from API
     case .failure(let error):
          //Error Message
     }
  }
 ```
### Advanced Queries

You can query for content types, entries, assets and more using our iOS API Reference.

[iOS API Reference Doc](https://www.contentstack.com/docs/platforms/swift/api-reference/)

### Working with Images

We have introduced Image Delivery APIs that let you retrieve images and then manipulate and optimize them for your digital properties. It lets you perform a host of other actions such as crop, trim, resize, rotate, overlay, and so on.

For example, if you want to crop an image (with width as 300 and height as 400), you simply need to append query parameters at the end of the image URL, such as, https://images.contentstack.io/v3/assets/blteae40eb499811073/bltc5064f36b5855343/59e0c41ac0eddd140d5a8e3e/download?crop=300,400. There are several more parameters that you can use for your images.

[Read Image Delivery API documentation](https://www.contentstack.com/docs/apis/image-delivery-api/).

You can use the Image Delivery API functions in this SDK as well. Here are a few examples of its usage in the SDK.

 ```
 /* set the image quality to 100 */
 let quality: UInt = 100
 let imageTransform = ImageTransform().qualiy(quality)
 let url = try imageURL.url(with: imageTransform)

 /* resize the image by specifying width and height */
 let width: UInt = 100
 let height: UInt = 100
 let urlboth = try imageURL
     .url(with: makeImageTransformSUT()
         .resize(
             Resize(size:
                 Size(width: width, height: height)
         )
     )
  )
 ```
[iOS API Reference Doc](https://www.contentstack.com/docs/platforms/swift/api-reference/)


### Using the Sync API with iOS SDK
The Sync API takes care of syncing your Contentstack data with your app and ensures that the data is always up-to-date by providing delta updates. Contentstack’s iOS SDK supports Sync API, which you can use to build powerful apps. Read through to understand how to use the Sync API with Contentstack iOS SDK.

#### Initial Sync
The Initial Sync process performs a complete sync of your app data. It returns all the published entries and assets of the specified stack in response.

To start the Initial Sync process, use the syncStack method.

 ```
let stack = Contentstack.stack(apiKey: apiKey,
              deliveryToken: deliveryToken,
              environment: environment)
 
stack.sync(then: { (result: Result<SyncStack, Error>) in
 switch result {
 case .success(let syncStack):
      let items = syncStack.items
      
      //error for any error description
      //syncStack for SyncStack
      //syncStack.syncToken: contains token for next sync Store this token For next sync
      //syncStack.paginationToken: contains token for next sync page this token for next sync
      //syncStack.items: contains sync data
      If let token = syncStack.paginationToken {
          UserDefault.standard.setValue(token, forKey:"PaginationToken")
      }else if let token = syncStack.syncToken {
          UserDefault.standard.setValue(token, forKey:"SyncToken")
      }

 case .failure(let error):
      print(error)
 }
})
 ```

The response also contains a sync token, which you need to store, since this token is used to get subsequent delta updates later, as shown in the Subsequent Sync section below. 

You can also fetch custom results in initial sync by using [advanced sync queries](#). 


#### Sync Pagination
If the result of the initial sync (or subsequent sync) contains more than 100 records, the response would be paginated. It provides pagination token in the response. However, you don’t have to use the pagination token manually to get the next batch; the SDK does that automatically, until the sync is complete. 

Pagination token can be used in case you want to fetch only selected batches. It is especially useful if the sync process is interrupted midway (due to network issues, etc.). In such cases, this token can be used to restart the sync process from where it was interrupted.

 ```
let stack = Contentstack.stack(apiKey: apiKey,
          deliveryToken: deliveryToken,
          environment: environment)

let syncStack = SyncStack(paginationToken: paginationToken)

stack.sync(syncStack, then: { (result: Result<SyncStack, Error>) in
 switch result {
 case .success(let syncStack):
      let items = syncStack.items
      
      //error for any error description
      //syncStack for SyncStack
      //syncStack.syncToken: contains token for next sync Store this token For next sync
      //syncStack.paginationToken: contains token for next sync page this token for next sync
      //syncStack.items: contains sync data
      If let token = syncStack.paginationToken {
          UserDefault.standard.setValue(token, forKey:"PaginationToken")
      }else if let token = syncStack.syncToken {
          UserDefault.standard.setValue(token, forKey:"SyncToken")
      }

 case .failure(let error):
      print(error)
 }
})
 ```
 
#### Subsequent Sync
You can use the sync token (that you receive after initial sync) to get the updated content next time. The sync token fetches only the content that was added after your last sync, and the details of the content that was deleted or updated.

 ```
let stack = Contentstack.stack(apiKey: apiKey,
          deliveryToken: deliveryToken,
          environment: environment)

let syncStack = SyncStack(syncToken: syncToken)

stack.sync(syncStack, then: { (result: Result<SyncStack, Error>) in
 switch result {
 case .success(let syncStack):
      let items = syncStack.items
      
      //error for any error description
      //syncStack for SyncStack
      //syncStack.syncToken: contains token for next sync Store this token For next sync
      //syncStack.paginationToken: contains token for next sync page this token for next sync
      //syncStack.items: contains sync data
      If let token = syncStack.paginationToken {
          UserDefault.standard.setValue(token, forKey:"PaginationToken")
      }else if let token = syncStack.syncToken {
          UserDefault.standard.setValue(token, forKey:"SyncToken")
      }

 case .failure(let error):
      print(error)
 }
})
 ```

#### Advanced sync queries
You can use advanced sync queries to fetch filtered results. Let's look at them in detail.

##### Initial sync from specific date
For initializing sync from a specific date, you can specify the date using the ```sync``` parameters.
 ```
let stack = Contentstack.stack(apiKey: apiKey,
          deliveryToken: deliveryToken,
          environment: environment)

let syncStack = SyncStack(syncToken: syncToken)

stack.sync(syncTypes: [.startFrom(date)], then: { (result: Result<SyncStack, Error>) in
 switch result {
 case .success(let syncStack):
      let items = syncStack.items
      
      //error for any error description
      //syncStack for SyncStack
      //syncStack.syncToken: contains token for next sync Store this token For next sync
      //syncStack.paginationToken: contains token for next sync page this token for next sync
      //syncStack.items: contains sync data
      If let token = syncStack.paginationToken {
          UserDefault.standard.setValue(token, forKey:"PaginationToken")
      }else if let token = syncStack.syncToken {
          UserDefault.standard.setValue(token, forKey:"SyncToken")
      }

 case .failure(let error):
      print(error)
 }
})
 ```
 ##### Initial sync of specific content types
 You can also initialize sync with entries of only specific content types. To do this, use syncOnly and specify the content type UID as its value.

 However, if you do this, the subsequent syncs will only include the entries of the specified content types.
  ```
 let stack = Contentstack.stack(apiKey: apiKey,
           deliveryToken: deliveryToken,
           environment: environment)

 let syncStack = SyncStack(syncToken: syncToken)

 stack.sync(syncTypes: [.contentType("contentTypeUID")], then: { (result: Result<SyncStack, Error>) in
  switch result {
  case .success(let syncStack):
       let items = syncStack.items
       
       //error for any error description
       //syncStack for SyncStack
       //syncStack.syncToken: contains token for next sync Store this token For next sync
       //syncStack.paginationToken: contains token for next sync page this token for next sync
       //syncStack.items: contains sync data
       If let token = syncStack.paginationToken {
           UserDefault.standard.setValue(token, forKey:"PaginationToken")
       }else if let token = syncStack.syncToken {
           UserDefault.standard.setValue(token, forKey:"SyncToken")
       }

  case .failure(let error):
       print(error)
  }
 })
  ```
##### Initial sync with specific language
You can also initialize sync with entries of only specific locales. To do this, use sync and specify the locale code as its value.

However, if you do this, the subsequent syncs will only include the entries of the specified locales.

 ```
let stack = Contentstack.stack(apiKey: apiKey,
          deliveryToken: deliveryToken,
          environment: environment)

let syncStack = SyncStack(syncToken: syncToken)

stack.sync(syncTypes: [.locale("en-gb")], then: { (result: Result<SyncStack, Error>) in
 switch result {
 case .success(let syncStack):
      let items = syncStack.items
      
      //error for any error description
      //syncStack for SyncStack
      //syncStack.syncToken: contains token for next sync Store this token For next sync
      //syncStack.paginationToken: contains token for next sync page this token for next sync
      //syncStack.items: contains sync data
      If let token = syncStack.paginationToken {
          UserDefault.standard.setValue(token, forKey:"PaginationToken")
      }else if let token = syncStack.syncToken {
          UserDefault.standard.setValue(token, forKey:"SyncToken")
      }

 case .failure(let error):
      print(error)
 }
})
 ```
 ##### Initial sync with publish type
 You can also initialize sync with entries and assets based on a specific publish type. The acceptable values are PublishType enums entryPublished, entryUnpublished, entryDeleted, assetPublished, assetUnpublished, assetDeleted, and contentTypeDeleted. To do this, use syncPublishType and specify the parameters.

 However, if you do this, the subsequent syncs will only include the entries of the specified publish type
  ```
 let stack = Contentstack.stack(apiKey: apiKey,
           deliveryToken: deliveryToken,
           environment: environment)

 let syncStack = SyncStack(syncToken: syncToken)

 stack.sync(syncTypes: [.publishType(.assetPublished)], then: { (result: Result<SyncStack, Error>) in
  switch result {
  case .success(let syncStack):
       let items = syncStack.items
       
       //error for any error description
       //syncStack for SyncStack
       //syncStack.syncToken: contains token for next sync Store this token For next sync
       //syncStack.paginationToken: contains token for next sync page this token for next sync
       //syncStack.items: contains sync data
       If let token = syncStack.paginationToken {
           UserDefault.standard.setValue(token, forKey:"PaginationToken")
       }else if let token = syncStack.syncToken {
           UserDefault.standard.setValue(token, forKey:"SyncToken")
       }

  case .failure(let error):
       print(error)
  }
 })
  ```
##### Initial sync with multiple parameters
For initializing sync with entries of specific content types, starting from specific date, use the snippet given below.

Note that subsequent syncs will only include the entries of the specified content types.
 ```
let stack = Contentstack.stack(apiKey: apiKey,
          deliveryToken: deliveryToken,
          environment: environment)

let syncStack = SyncStack(syncToken: syncToken)

stack.sync(syncTypes: [.locale("en-gb"), .contentType("contentTypeUID")], then: { (result: Result<SyncStack, Error>) in
 switch result {
 case .success(let syncStack):
      let items = syncStack.items
      
      //error for any error description
      //syncStack for SyncStack
      //syncStack.syncToken: contains token for next sync Store this token For next sync
      //syncStack.paginationToken: contains token for next sync page this token for next sync
      //syncStack.items: contains sync data
      If let token = syncStack.paginationToken {
          UserDefault.standard.setValue(token, forKey:"PaginationToken")
      }else if let token = syncStack.syncToken {
          UserDefault.standard.setValue(token, forKey:"SyncToken")
      }

 case .failure(let error):
      print(error)
 }
})
 ```

### Helpful Links

- [Contentstack Website](https://www.contentstack.com)
- [Official Documentation](http://contentstack.com/docs)
- [Content Delivery API Docs](https://contentstack.com/docs/apis/content-delivery-api/)
