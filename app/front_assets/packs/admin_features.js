import { Application } from "@hotwired/stimulus";
import AdminSearchController from "../controllers/admin_search_controller";

const application = Application.start();
application.register("admin-search", AdminSearchController);
